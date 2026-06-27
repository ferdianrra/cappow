extends Node2D

@export var grass_scene: PackedScene  # drag Grass.tscn ke field ini di Inspector
@export var arena_radius = 280.0
@export var max_grass_count = 5       # jumlah rumput maksimal yang ada bersamaan
@export var spawn_interval = 2.0      # tiap berapa detik coba spawn rumput baru

var current_grass_count = 0

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.timeout.connect(_try_spawn_grass)
	add_child(timer)
	add_to_group("game_scene")
	timer.start()
	
	# Spawn awal beberapa rumput langsung pas game mulai
	for i in max_grass_count:
		_spawn_grass()

func _try_spawn_grass():
	if current_grass_count < max_grass_count:
		_spawn_grass()

func _spawn_grass():
	var grass = grass_scene.instantiate()
	add_child(grass)
	grass.position = _get_random_point_in_circle()
	
	current_grass_count += 1
	grass.tree_exited.connect(_on_grass_removed)

func _on_grass_removed():
	current_grass_count -= 1

func _get_random_point_in_circle() -> Vector2:
	var angle = randf() * TAU
	var distance = sqrt(randf()) * arena_radius
	return Vector2(cos(angle), sin(angle)) * distance
