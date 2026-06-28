extends TextureButton

@export var player_text: String = "1P"
@onready var label_node = $MarginContainer/VBoxContainer/Label
signal click_finished

func _ready():
	# Saat game dijalankan, ganti tulisan di Label sesuai dengan inputan player_text di Inspector
	if label_node:
		label_node.text = player_text
	
	pivot_offset = size / 2


func _on_button_down() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color(0.9, 0.9, 0.9), 0.15)

func _on_button_up() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.2)
	if is_hovered():
		click_finished.emit()
