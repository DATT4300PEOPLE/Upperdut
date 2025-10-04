extends CharacterBody2D

@export var defaultSpeed = 670
@export var jump_power: float # HAS TO BE NEGATIVE (FORGOT) ALSO ADJUSTABLE BY GLOBAL
@export var sprite_character: CharacterBody2D
@export var PLAYER: PLAYER_TYPE
var currentSpeed: float
var currentAccel: float

enum PLAYER_TYPE {
	P1,
	P2
}


func _ready() -> void:
	currentSpeed = defaultSpeed
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
	get_input()
	move_and_slide()
	

func get_input():
	var direction
	var jumpKey
	if PLAYER == 0:
		direction = Input.get_axis("P1Left", "P1Right")
		jumpKey = "P1Jump"
	else:
		direction = Input.get_axis("P2Left", "P2Right")
		jumpKey = "P2Jump"
	if direction:
		velocity.x = direction * currentSpeed
	else:
		velocity.x = 0
	if Input.is_action_just_pressed(jumpKey) and is_on_floor():
		print("JUMPIGN")
		velocity.y = jump_power
	if Input.is_action_just_released(jumpKey) and is_on_floor():
		print("JUMPIGN")
		velocity.y = jump_power / 2
