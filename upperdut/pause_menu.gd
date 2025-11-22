extends Node2D
@onready var play: TextureButton = $PausePlaceholder/Play
@onready var settings: TextureButton = $PausePlaceholder/Settings
@onready var quit: TextureButton = $PausePlaceholder/Quit
@onready var tutorial: TextureButton = $PausePlaceholder/Tutorial
@onready var pause: TextureButton = $Pause
@onready var pause_placeholder: Sprite2D = $PausePlaceholder


func _process(delta: float) -> void:
	if play.button_pressed:
		pause_placeholder.visible = false
		pause.visible = true
	if quit.button_pressed:
		get_tree().quit()
	if pause.button_pressed:
		pause_placeholder.visible = true
		pause.visible = false
