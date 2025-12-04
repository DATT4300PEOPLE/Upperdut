extends Node

@export var P1_Damage: float
@export var P2_Damage: float
@export var P1_Stock: int
@export var P2_Stock: int

@export var P1_onLadder: bool
@export var P2_onLadder: bool

@export var P1_onSwitch: bool
@export var P2_onSwitch: bool

@export var Belt_Pieces = []
@export var Game_Over: bool = false
func _ready() -> void:
	P1_Damage = 0
	P2_Damage = 0
	P1_Stock = 3
	P2_Stock = 3
	P1_onLadder = false
	P2_onLadder = false
	

func apply_damage(damage: int, player: int):
	if (player == 0):
		P1_Damage += damage
		print("P1 Meter: ", P1_Damage, "%" )
	else:
		P2_Damage += damage
		print("P2 Meter: ", P2_Damage, "%" )
	if P1_Damage > 130:
		P1_Damage = 0
		P1_Stock -= 1
		print(P2_Stock)
	if P2_Damage >= 130:
		P2_Damage = 0
		P2_Stock -= 1
		print(P2_Stock)
	if P2_Damage <= 0:
		P2_Damage = 0
	if P2_Stock <= 0 or P1_Stock <= 0:
		get_tree().change_scene_to_file("res://death_screen.tscn")
		P1_Damage = 0
		P2_Damage = 0
		P1_Stock = 3
		P2_Stock = 3
		P1_onLadder = false
		P2_onLadder = false

func apply_movement(player: float, damage_deduction: int = 0, jumping: bool = false) -> int:
	if (player == 0):
		if P1_Damage > 0 and jumping == true:
			P1_Damage -= damage_deduction
		return P1_Damage * 1.5
	if (player == 1):
		if P2_Damage > 0 and jumping == true:
			P2_Damage -= damage_deduction
		return P2_Damage * 1.5
	return 0
