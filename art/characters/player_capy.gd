extends CharacterBody2D

@export var player_id: int = 1
@export var move_speed: float = 300.0
@export var arena_radius: float = 280.0
@export var growth_per_grass: float = 0.15  # seberapa besar nambah scale tiap makan 1 rumput
@export var max_scale: float = 3.0
@export var outside_scale: float = 0.4
@export var transition_speed: float = 0.25
@export var bounce_force: float = 400.0
@export var joystick_node: Control

const PLAYER_FRAMES = {
	1: preload("res://art/characters/capy_basic.tres"),  # P1 - Cokelat
	2: preload("res://art/characters/capy_green.tres"),  # P2 - Hijau
	3: preload("res://art/characters/capy_red.tres"),    # P3 - Merah
	4: preload("res://art/characters/capy_yellow.tres")   # P4 - Kuning
}

@onready var animated_sprite = $CapybaraWalk

var arena_center: Vector2
var is_outside = false
var is_bounced = false
var is_punching = false
var is_respawning = false 
var last_attacker_id: int = -1   
var original_collision_layer: int = 0
var original_collision_mask: int = 0

func _ready():
	arena_center = get_parent().global_position
	add_to_group("capybara")
	if PLAYER_FRAMES.has(player_id):
		animated_sprite.sprite_frames = PLAYER_FRAMES[player_id]
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")

func _physics_process(_delta):
	var input_dir = get_player_input()
	update_sprite_animation(input_dir)
	
	if not is_bounced:
		velocity = input_dir * move_speed
	
	move_and_slide()
	
	check_collision_with_others()
	check_arena_boundary()
	update_rotation(input_dir)

func get_player_input() -> Vector2:
	if joystick_node:
		return joystick_node.output_vector

	match player_id:
		1: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		2: return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		3: return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		4: return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
			
	return Vector2.ZERO

func check_collision_with_others():
	if is_respawning:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("capybara") and collider != self:
			if "is_respawning" in collider and collider.is_respawning:
				continue

			var bounce_direction = collision.get_normal() * -1
			var applied_force = bounce_force * scale.x

			trigger_punch()
			
			if collider.has_method("get_bounced"):
				collider.get_bounced(bounce_direction, applied_force, player_id) 
				
func get_bounced(direction: Vector2, force: float, attacker_id: int = -1):
	if is_respawning:
		return

	is_bounced = true
	last_attacker_id = attacker_id 
	velocity = direction * force
	await get_tree().create_timer(0.3).timeout
	is_bounced = false

func update_rotation(movie_input: Vector2):
	if movie_input != Vector2.ZERO:
		rotation = movie_input.angle()

func grow_from_grass():
	if is_outside:
		return 

	var new_scale_magnitude = scale.x + growth_per_grass
	new_scale_magnitude = clamp(new_scale_magnitude, 0.1, max_scale)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * new_scale_magnitude, 0.2)

func update_sprite_animation(movie_input: Vector2):
	if is_punching:
		return 
	if movie_input != Vector2.ZERO:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func trigger_punch():
	if not is_punching:
		is_punching = true
		animated_sprite.play("punch")

func _on_animation_finished():
	if animated_sprite.animation == "punch":
		is_punching = false 

func check_arena_boundary():
	if is_outside:
		return  
		
	var distance_from_center = global_position.distance_to(arena_center)
	
	if distance_from_center > arena_radius:
		is_outside = true
		on_exit_arena()

func on_exit_arena():
	var game_scene = get_tree().get_first_node_in_group("game_scene")
	if game_scene and game_scene.has_method("on_player_killed"):
		if last_attacker_id != -1:
			game_scene.on_player_killed(last_attacker_id)

	last_attacker_id = -1
	
	visible = false
	set_physics_process(false)
	
	await get_tree().create_timer(1.0).timeout  # delay respawn 1 detik
	
	respawn()
	
func respawn():
	var active_tweens = get_tree().get_processed_tweens()
	for t in active_tweens:
		if t.is_valid():
			t.kill()

	var max_random_radius = arena_radius * 0.7
	var random_distance = randf_range(0.0, max_random_radius)
	var random_angle = randf_range(0.0, 2.0 * PI)
	var random_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	global_position = arena_center + random_offset
	scale = Vector2(0.5, 0.5) 
	
	visible = true
	is_outside = false
	
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	collision_layer = 0 
	collision_mask = 0  
	
	set_physics_process(true)
	is_respawning = true
	
	var blink_duration = 0.125 * 2 * 8  # 8 loop x (fade out + fade in)
	var tween = create_tween().set_loops(8) 
	tween.tween_property(animated_sprite, "modulate:a", 0.2, 0.125) 
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.125) 
	
	# Restore dijadwalkan lewat timer terpisah, BUKAN await tween yang bisa dibunuh
	await get_tree().create_timer(blink_duration).timeout

	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	force_update_transform()

	animated_sprite.modulate.a = 1.0
	is_respawning = false
