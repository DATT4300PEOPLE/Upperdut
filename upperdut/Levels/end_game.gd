extends Area2D
@onready var player_1: CharacterBody2D = $"../Player 1"
@onready var player_2: CharacterBody2D = $"../Player 2"
@onready var end_pos_1: Sprite2D = $"../EndPos1"
@onready var end_pos_2: Sprite2D = $"../EndPos2"
@onready var belt_combine_anim: AnimationPlayer = $"../Belt/AnimationPlayer"
@onready var belt_drop_anim: AnimationPlayer = $"../FullBelt/AnimationPlayer"
@onready var black_fade_anim: AnimationPlayer = $"../BlackFade/AnimationPlayer"
@onready var camera_2d: Camera2D = $"../Camera2D"


func _on_area_entered(area: Area2D) -> void:
	if (area.owner.name == "Player 1" or area.owner.name == "Player 2") and PlayerData.Belt_Pieces.size() >= 2:
		player_1.position = end_pos_1.position
		player_2.position = end_pos_2.position
		PlayerData.Game_Over = true
		camera_2d.position = Vector2(581, -4725.0)
		belt_combine_anim.play("BeltTogether")
		belt_drop_anim.play("BeltSlide")
		black_fade_anim.play("FadeInBlack")
		await get_tree().create_timer(12).timeout
		get_tree().change_scene_to_file("res://main_menu.tscn")
