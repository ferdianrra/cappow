extends AnimatedSprite2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	play("default")  # ← must match exactly
	animation_finished.connect(queue_free)
	
	# 3. Play the punch sound effect!
	if audio_player and audio_player.stream:
		audio_player.play()
