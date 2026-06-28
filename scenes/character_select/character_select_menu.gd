extends Control

@onready var btn_1 = $VBoxContainer/select_player_section/people_player_button
@onready var btn_2 = $VBoxContainer/select_player_section/people_player_button2
@onready var btn_3 = $VBoxContainer/select_player_section/people_player_button3
@onready var btn_4 = $VBoxContainer/select_player_section/people_player_button4
@onready var btn_back = $Control/BackButton

func _ready():
	# Hubungkan semua tombol ke fungsinya masing-masing
	btn_1.click_finished.connect(_on_btn_1_completed)
	btn_2.click_finished.connect(_on_btn_2_completed)
	btn_3.click_finished.connect(_on_btn_3_completed)
	btn_4.click_finished.connect(_on_btn_4_completed)
	btn_back.click_finished.connect(_on_back_button_completed)
	
func _on_btn_1_completed() -> void:
	Global.selected_players = 1
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_btn_2_completed() -> void:
	Global.selected_players = 2
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_btn_3_completed() -> void:
	Global.selected_players = 3
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_btn_4_completed() -> void:
	Global.selected_players = 4
	get_tree().change_scene_to_file("res://scenes/test/game_scene_arena.tscn")


func _on_back_button_completed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
