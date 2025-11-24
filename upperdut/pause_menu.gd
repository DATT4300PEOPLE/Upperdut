extends Node2D
@onready var play: TextureButton = $PausePlaceholder/Play
@onready var settings: TextureButton = $PausePlaceholder/Settings
@onready var quit: TextureButton = $PausePlaceholder/Quit
@onready var tutorial: TextureButton = $PausePlaceholder/Tutorial
@onready var pause: TextureButton = $Pause
@onready var pause_placeholder: Sprite2D = $PausePlaceholder
@onready var tutorialpic: Sprite2D = $PausePlaceholder/TutorialPic
@onready var tutorialback: TextureButton = $PausePlaceholder/TutorialBack


func _process(delta: float) -> void:
	if play.button_pressed:
		pause_placeholder.visible = false
		pause.visible = true
		tutorialpic.visible = false
		tutorialback.visible = false
	
	if quit.button_pressed:
		get_tree().quit()
	
	if pause.button_pressed:
		pause_placeholder.visible = true
		pause.visible = false
		tutorialpic.visible = false
		tutorialback.visible = false
	
	if tutorial.button_pressed:
		tutorialpic.visible = true
		tutorialback.visible = true
	
	if tutorialback.button_pressed:
		tutorialpic.visible = false
		tutorialback.visible = false
