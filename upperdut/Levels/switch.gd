extends Area2D

@export var platform: Sprite2D


func platform_state() -> void:
	platform.visible = !platform.visible
