extends TextureButton
@onready var play: TextureButton = $"."

func _process(delta: float) -> void:
	if play.pressed:
		get_tree().change_scene_to_file("res://Levels/level_one.tscn")
