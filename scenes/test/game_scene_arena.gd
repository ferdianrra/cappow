extends Node2D

# "Tangkap" node UI dan Timer-nya
# Pastikan path-nya sesuai dengan susunan di Scene Tree-mu
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var game_timer = $GameTimer
@onready var score_1p = $CanvasLayer/ZoneBottomLeft/VBoxContainer/ScoreBg_1P/MarginContainer/HBoxContainer/Score1P
@onready var score_2p = $CanvasLayer/ZoneTopRight/VBoxContainer/ScoreBg_2P/MarginContainer/HBoxContainer/Score2P
@onready var score_3p = $CanvasLayer/ZoneBottomRight/VBoxContainer/ScoreBg_3P/MarginContainer/HBoxContainer/Score3P
@onready var score_4p = $CanvasLayer/ZoneTopLeft/VBoxContainer/ScoreBg_4P/MarginContainer/HBoxContainer/Score4P

# Menyimpan jumlah mati tiap player (awalnya 0 semua)
var death_counts = {
	1: 0,
	2: 0,
	3: 0,
	4: 0
}

var is_game_over: bool = false 
var winner_screen_scene = preload("res://scenes/winner/winner_layer.tscn")

func _process(delta):
	if is_game_over:
		return
		
	if game_timer.time_left > 0:
		var time_left = game_timer.time_left
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		
		timer_label.text = "%02d:%02d" % [minutes, seconds]
	else:
		timer_label.text = "00:00"
		
		is_game_over = true
		var winner = _find_winner()
		_on_game_over(winner.id, winner.kills)
		
func _ready():
	add_to_group("game_scene") 
	if Global.selected_players < 4:
		$CanvasLayer/AspectRatioContainer/Arena/PlayerCapy4.queue_free()
		$CanvasLayer/ZoneTopLeft.queue_free()
		score_4p.hide() 
		
	if Global.selected_players < 3:
		$CanvasLayer/AspectRatioContainer/Arena/PlayerCapy3.queue_free()
		$CanvasLayer/ZoneBottomRight.queue_free()
		score_3p.hide()
		
	if Global.selected_players < 2:
		$CanvasLayer/AspectRatioContainer/Arena/PlayerCapy2.queue_free()
		$CanvasLayer/ZoneTopRight.queue_free()
		score_2p.hide() 


func on_player_killed(player_id: int):
	if is_game_over:
		return
		
	death_counts[player_id] += 1
	_update_score_label(player_id)
	
func _on_game_over(player_id, kills):
	Global.winner_id = player_id
	Global.winner_kills = kills
	var winner_screen = winner_screen_scene.instantiate()
	add_child(winner_screen)
	get_tree().paused = true

func _find_winner():
	var max_kills = -1
	var winner_id = 1
	
	for id in death_counts:
		if death_counts[id] > max_kills:
			max_kills = death_counts[id]
			winner_id = id
			
	return {"id": winner_id, "kills": max_kills}
	
func _update_score_label(player_id: int):
	match player_id:
		1:
			score_1p.text = str(death_counts[1])
		2:
			score_2p.text = str(death_counts[2])
		3:
			score_3p.text = str(death_counts[3])
		4:
			score_4p.text = str(death_counts[4])
