extends TextureButton

@export var player_text: String = "1P"

# "Tangkap" node Label yang ada di dalam card ini
# PASTIKAN path nodenya ($MarginContainer/...) sesuai dengan susunanmu!
@onready var label_node = $MarginContainer/VBoxContainer/Label

func _ready():
	# Saat game dijalankan, ganti tulisan di Label sesuai dengan inputan player_text di Inspector
	if label_node:
		label_node.text = player_text
