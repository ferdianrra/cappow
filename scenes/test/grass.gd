extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.sprite_frames.set_animation_loop("appear", false)
	sprite.play("appear")
	sprite.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)

func _on_animation_finished() -> void:
	if sprite.animation == "appear":
		sprite.play("idle")


func _on_body_entered(body):
	if body.is_in_group("capybara"):
		if body.has_method("grow_from_grass"):
			body.grow_from_grass()
		queue_free()
