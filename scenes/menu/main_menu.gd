extends Control

@onready var btn_play = $VBoxContainer/PlayButton
@onready var btn_guide = $VBoxContainer/GuideButton

func _ready():
	btn_play.click_finished.connect(_on_play_btn_completed)
	btn_guide.click_finished.connect(_on_guide_btn_completed)
	
func _on_play_btn_completed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select_menu.tscn")


func _on_guide_btn_completed() -> void:
	get_tree().change_scene_to_file("res://scenes/guide_game/guide_game.tscn")
