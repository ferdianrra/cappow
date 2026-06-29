extends AnimatedSprite2D

func _ready() -> void:
	play("default")  # ← must match exactly
	animation_finished.connect(queue_free)
