extends Camera2D

@onready var p1: CharacterBody2D = $"../Player 1"
@onready var p2: CharacterBody2D = $"../Player 2"
@onready var pause_menu: Node2D = $"../Camera2D/CanvasLayer/Pause Menu"
@onready var player_data_ui: Node2D = $CanvasLayer/PlayerDataUI

@export var min_zoom := Vector2(1, 1)
@export var max_zoom := Vector2(2, 2)
@export var zoom_smoothness := 5.0
@export var move_smoothness := 5.0

@onready var blue_icon: Sprite2D = $"../BlueIcon"
@onready var red_icon: Sprite2D = $"../RedIcon"



func _physics_process(delta: float) -> void:
	print(PlayerData.Game_Over )
	if PlayerData.Game_Over:
		zoom = Vector2(1,1)
		offset = Vector2(0,0)
		position = Vector2(581, -4725.0)
		pause_menu.visible = false
		player_data_ui.visible = false
		return
	else:
		if not p1 or not p2:
			return
		var top_y = min(p1.global_position.y, p2.global_position.y)
		var bottom_y = max(p1.global_position.y, p2.global_position.y)

		var midpoint = Vector2(
			position.x,
			(top_y + bottom_y) * 0.5
		)

		global_position = global_position.lerp(midpoint, delta * move_smoothness)

		var vertical_distance = bottom_y - top_y
		var target_zoom = lerp(max_zoom, min_zoom, clamp((vertical_distance - 200.0) / 600.0, 0.0, 1.0))
		
		if (p1.position.y >= position.y + 200):
			red_icon.position.x = p1.position.x
			red_icon.position.y = position.y + 250
			red_icon.visible = true
		else:
			red_icon.visible = false
		if (p2.position.y > position.y + 200):
			blue_icon.position.x = p2.position.x
			blue_icon.position.y = position.y + 250
			blue_icon.visible = true
		else:
			blue_icon.visible = false
		
		zoom = zoom.lerp(target_zoom, delta * zoom_smoothness)
