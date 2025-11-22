extends TextureButton
@onready var play: TextureButton = $"."
@onready var exit: TextureButton = $"../Exit"

func _process(delta: float) -> void:
	if play.button_pressed:
		get_tree().change_scene_to_file("res://Levels/level_one.tscn")
	if exit.button_pressed:
		get_tree().quit()
