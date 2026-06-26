extends Control

@onready var point = $Point

var output_vector: Vector2 = Vector2.ZERO
var current_touch_index: int = -1

func _ready() -> void:
	await get_tree().process_frame
	point.position = (size / 2) - (point.size / 2)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and current_touch_index == -1:
			# Cek apakah sentuhan ada di dalam area joystick
			if get_global_rect().has_point(event.position):
				current_touch_index = event.index
				update_joystick(event.position)
		elif not event.pressed and event.index == current_touch_index:
			current_touch_index = -1
			output_vector = Vector2.ZERO
			point.position = (size / 2) - (point.size / 2)

	elif event is InputEventScreenDrag:
		if event.index == current_touch_index:
			update_joystick(event.position)

func update_joystick(touch_position: Vector2) -> void:
	var center = global_position + size / 2  # pakai global karena input pakai global coords
	var radius = size.x / 2
	var local_pos = touch_position - center

	if local_pos.length() > radius:
		local_pos = local_pos.normalized() * radius

	point.position = (size / 2) + local_pos - (point.size / 2)
	output_vector = local_pos / radius  # normalized -1 to 1
