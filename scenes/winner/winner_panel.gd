extends Panel

@onready var player_label = $WinnerContainer/WinnerBackground/MarginContainer/VBoxContainer/WinnerSectionBackground/VBoxContainer/LabelPlayer
@onready var kills_label = $WinnerContainer/WinnerBackground/MarginContainer/VBoxContainer/WinnerSectionBackground/VBoxContainer/HBoxContainer/HBoxContainer/TotalKillLabel
func _ready():
	# Munculkan data pemenang
	player_label.text = "PLAYER " + str(Global.winner_id)
	kills_label.text = str(Global.winner_kills)
	
	# Animasi muncul pop-up (seperti yang kita bahas sebelumnya)
	pivot_offset = size / 2
	scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
