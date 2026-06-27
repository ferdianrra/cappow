extends Control

func _on_people_player_button_pressed() -> void:
	Global.selected_players = 1
	#get_tree().change_scene_to_file("res://scenes/test/test_Scene_tiles_map.tscn")

	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_people_player_button_2_pressed() -> void:
	Global.selected_players = 2
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_people_player_button_3_pressed() -> void:
	Global.selected_players = 3
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_people_player_button_4_pressed() -> void:
	Global.selected_players = 4
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")
