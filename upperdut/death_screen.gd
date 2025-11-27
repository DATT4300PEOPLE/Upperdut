extends TextureButton
@onready var restart: TextureButton = $"."
@onready var quit: TextureButton = $"../Quit"

func _process(delta: float) -> void:
	if restart.button_pressed:
		get_tree().change_scene_to_file("res://Levels/level_one.tscn")
	if quit.button_pressed:
		get_tree().change_scene_to_file("res://main_menu.tscn")
