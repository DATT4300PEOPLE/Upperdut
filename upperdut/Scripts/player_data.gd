extends Node

@export var P1_Damage: float
@export var P2_Damage: float

@export var P1_onLadder: bool
@export var P2_onLadder: bool

@export var P1_onSwitch: bool
@export var P2_onSwitch: bool

func _ready() -> void:
	P1_Damage = 0
	P2_Damage = 0
	P1_onLadder = false
	P2_onLadder = false
	
func _physics_process(delta: float) -> void:
	if P1_Damage > 150:
		P1_Damage = 100
	if P2_Damage >= 150:
		P2_Damage = 100

func apply_damage(damage: int, player: int):
	if (player == 0):
		P1_Damage += damage
		print("P1 Meter: ", P1_Damage, "%" )
	else:
		P2_Damage += damage
		print("P2 Meter: ", P2_Damage, "%" )

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
