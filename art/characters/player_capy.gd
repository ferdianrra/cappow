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

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var arena_center: Vector2
var is_outside = false
var is_bounced = false
var last_attacker_id: int = -1  
func _ready():
	arena_center = get_parent().global_position
	add_to_group("capybara")  # pastikan masuk group ini biar collision & grass detection jalan

func _physics_process(_delta):
	var input_dir = get_player_input()
	update_animation_parameters(input_dir)
	
	if not is_bounced:
		velocity = input_dir * move_speed
	
	move_and_slide()
	
	check_collision_with_others()
	check_arena_boundary()
	update_rotation(input_dir)

func get_player_input() -> Vector2:
	# Jika joystick node sudah terpasang, ambil nilainya
	if joystick_node:
		return joystick_node.output_vector
	
	# Fallback (opsional): Kalau tidak ada joystick, tetap bisa pakai keyboard
	match player_id:
		1:
			return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		2:
			return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		3:
			return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		4:
			return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
			
	return Vector2.ZERO

func check_collision_with_others():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("capybara") and collider != self:
			var bounce_direction = collision.get_normal() * -1
			
			# Makin besar scale capybara ini, makin kenceng dorongannya
			var applied_force = bounce_force * scale.x
			
			if collider.has_method("get_bounced"):
				collider.get_bounced(bounce_direction, applied_force, player_id)  # <- kirim player_id "gue"
				
func get_bounced(direction: Vector2, force: float, attacker_id: int = -1):
	is_bounced = true
	last_attacker_id = attacker_id  # <- catat siapa yang baru nabrak
	velocity = direction * force
	await get_tree().create_timer(0.3).timeout
	is_bounced = false

func update_rotation(movie_input: Vector2):
	if movie_input != Vector2.ZERO:
		rotation = movie_input.angle()

func grow_from_grass():
	if is_outside:
		return  # gak nambah growth kalau pas lagi di luar arena
	
	# Sedikit penyesuaian: pakai scale.x agar lebih konsisten dengan hitungan bounce
	var new_scale_magnitude = scale.x + growth_per_grass
	new_scale_magnitude = clamp(new_scale_magnitude, 0.1, max_scale)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * new_scale_magnitude, 0.2)

func update_animation_parameters(movie_input: Vector2):
	if movie_input != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", movie_input)
		animation_tree.set("parameters/Idle/blend_position", movie_input)
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func check_arena_boundary():
	if is_outside:
		return  # udah dalam proses respawn, skip biar gak ke-trigger dobel
		
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
	global_position = arena_center
	scale = Vector2.ONE
	visible = true
	is_outside = false
	set_physics_process(true)
