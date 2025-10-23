extends Camera2D

@onready var p1: CharacterBody2D = $"../Player 1"
@onready var p2: CharacterBody2D = $"../Player 2"

@export var min_zoom := Vector2(1, 1)
@export var max_zoom := Vector2(2, 2)
@export var zoom_smoothness := 5.0
@export var move_smoothness := 5.0

func _physics_process(delta: float) -> void:
	if not p1 or not p2:
		return
	var top_y = min(p1.global_position.y, p2.global_position.y)
	var bottom_y = max(p1.global_position.y, p2.global_position.y)

	var midpoint = Vector2(
		(p1.global_position.x + p2.global_position.x) * 0.5,
		(top_y + bottom_y) * 0.5
	)

	global_position = global_position.lerp(midpoint, delta * move_smoothness)

	var vertical_distance = bottom_y - top_y
	var target_zoom = lerp(max_zoom, min_zoom, clamp((vertical_distance - 200.0) / 600.0, 0.0, 1.0))

	zoom = zoom.lerp(target_zoom, delta * zoom_smoothness)
