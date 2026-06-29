extends CharacterBody2D

@export var player_id: int = 1
@export var move_speed: float = 300.0
@export var arena_radius: float = 280.0
@export var growth_per_grass: float = 0.15
@export var max_scale: float = 3.0
@export var outside_scale: float = 0.4
@export var transition_speed: float = 0.25
@export var bounce_force: float = 400.0
@export var joystick_node: Control
@export var size_speed_penalty: float = 0.5 

# Add this new export to assign SpriteFrames per player
@export var sprite_frames: SpriteFrames

@onready var animated_sprite = $AnimatedSprite2D

var arena_center: Vector2
var is_outside = false
var is_bounced = false
var is_punching = false

func _ready():
	arena_center = get_parent().global_position
	add_to_group("capybara")
	
	# Apply the assigned SpriteFrames resource
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
	
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	var input_dir = get_player_input()
	
	if not is_bounced:
		var growth_ratio = (scale.x - 1.0) / (max_scale - 1.0)
		growth_ratio = clamp(growth_ratio, 0.0, 1.0)
		
		var speed_multiplier = 1.0 - growth_ratio * size_speed_penalty
		velocity = input_dir * move_speed * speed_multiplier
	
	move_and_slide()
	
	check_collision_with_others()
	check_arena_boundary()
	update_rotation(input_dir)
	update_sprite_animation(input_dir)

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
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("capybara") and collider != self:
			var bounce_direction = collision.get_normal() * -1
			var applied_force = bounce_force * scale.x
			trigger_punch()
			
			if collider.has_method("get_bounced"):
				collider.get_bounced(bounce_direction, applied_force)

func get_bounced(direction: Vector2, force: float):
	is_bounced = true
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
	var distance_from_center = global_position.distance_to(arena_center)
	var currently_outside = distance_from_center > arena_radius
	
	if currently_outside:
		var direction_to_center = (global_position - arena_center).normalized()
		global_position = arena_center + direction_to_center * arena_radius
	
	if currently_outside and not is_outside:
		is_outside = true
		on_exit_arena()
	elif not currently_outside and is_outside:
		is_outside = false
		on_enter_arena()

func on_exit_arena():
	print(name, " keluar arena!")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * outside_scale, transition_speed)

func on_enter_arena():
	print(name, " masuk arena lagi!")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, transition_speed)
