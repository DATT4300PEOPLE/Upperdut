class_name  player_hitbox
extends Area2D


@export var damage := 5
@export var player_ID: String

func _init() -> void:
	collision_layer = 3
	collision_mask = 0
