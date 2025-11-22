extends Node2D
@onready var pause: TextureButton = $Camera2D/CanvasLayer/Pause
@onready var pause_menu: Node2D = $"Camera2D/CanvasLayer/Pause Menu"

func _process(delta: float) -> void:
	if pause.button_pressed:
		pause_menu.visible = true
		pause.visible = false
