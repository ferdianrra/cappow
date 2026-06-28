extends Panel

@onready var player_label = $WinnerContainer/WinnerBackground/MarginContainer/VBoxContainer/WinnerSectionBackground/VBoxContainer/LabelPlayer
@onready var kills_label = $WinnerContainer/WinnerBackground/MarginContainer/VBoxContainer/WinnerSectionBackground/VBoxContainer/HBoxContainer/HBoxContainer/TotalKillLabel
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	player_label.text = "PLAYER " + str(Global.winner_id)
	kills_label.text = str(Global.winner_kills)
	
	pivot_offset = size / 2
	scale = Vector2(0, 0) # Ubah jadi 0 agar animasi TRANS_BACK terasa pop-up
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3)

func _on_play_again_button_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
