extends Control

var current_page = 0

@onready var action_btn =$MarginContainer/GuidePlayContainer/NavgiationContainer/TextureButton
@onready var slides_container = $MarginContainer/GuidePlayContainer
@onready var dot_1 = $MarginContainer/GuidePlayContainer/NavgiationContainer/DotContainer/Dot1
@onready var dot_2 = $MarginContainer/GuidePlayContainer/NavgiationContainer/DotContainer/Dot2
@onready var slides_manager = $MarginContainer/GuidePlayContainer/Slides
@onready var buttonLabel = $MarginContainer/GuidePlayContainer/NavgiationContainer/TextureButton/NextLabel
@onready var btn_back = $MarginContainer/GuidePlayContainer/BackButton

const COLOR_ACTIVE = Color("#47331C")   
const COLOR_INACTIVE = Color("#FFFFFF") 

func _ready():
	slides_container.position.x = 0
	btn_back.click_finished.connect(_on_back_button_completed)
	action_btn.click_finished.connect(_on_action_button_completed)	
	update_ui()

		
func update_ui():
	if current_page == 0:
		dot_1.modulate = COLOR_ACTIVE
		dot_2.modulate = COLOR_INACTIVE
		buttonLabel.text = "Next"
	else:
		dot_1.modulate = COLOR_INACTIVE
		dot_2.modulate = COLOR_ACTIVE
		buttonLabel.text = "Got It!"


func  _on_action_button_completed() -> void:
	if current_page == 0:
		current_page = 1
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		# Menggeser seluruh wadah besar agar Page 2 masuk ke layar
		tween.tween_property(slides_manager, "position:x", -1152, 0.5) 
		update_ui()
	else:
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_back_button_completed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
