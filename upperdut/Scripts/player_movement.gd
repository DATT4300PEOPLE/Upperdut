extends CharacterBody2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: player_hitbox = $PlayerSprite/BoxingGlove/player_hitbox

# MAKE FIST OBJECT MONITORABLE AND MOVE FORWARD UPON PUNCHING
@onready var boxing_glove: AnimatedSprite2D = $PlayerSprite/BoxingGlove
@export var defaultSpeed = 670
@export var jump_power: float # HAS TO BE NEGATIVE (FORGOT) ALSO ADJUSTABLE BY GLOBAL
@export var sprite_character: CharacterBody2D
@export var PLAYER: PLAYER_TYPE
var dir_facing = 1
var currentSpeed: float
var currentAccel: float
var doing_action = false
enum PLAYER_TYPE {P1,P2}

func _ready() -> void:
	currentSpeed = defaultSpeed
	player_sprite.animation_finished.connect(_on_animation_finished)
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
	if velocity.x == 0 and is_on_floor() and !doing_action:
		player_sprite.play("Idle")
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
		if direction != 0:
			dir_facing = direction
			if direction < 0:
				player_sprite.scale.x = -0.49 # DON'T HARDCODE THIS IN, FIX LATER
			else:
				player_sprite.scale.x = 0.49 # DON'T HARDCODE THIS IN, FIX LATER
			player_sprite.play("Walk")
		velocity.x = direction * currentSpeed
	else:
		velocity.x = 0
	get_fight_input(direction)
	if Input.is_action_just_pressed(jumpKey) and is_on_floor():
		print("JUMPIGN")
		player_sprite.play("Jump")
		velocity.y = jump_power
	if Input.is_action_just_released(jumpKey) and is_on_floor():
		print("JUMPIGN")
		player_sprite.play("Jump")
		velocity.y = jump_power / 2

func get_fight_input(direction: int):
	var punchBtn
	if PLAYER == 0:
		punchBtn = "P1Punch"
	else:
		punchBtn = "P2Punch"
	if Input.is_action_just_pressed(punchBtn):
		player_sprite.play("Punch")
		doing_action = true
		boxing_glove.visible = true
		boxing_glove.position.x = 173.386
		player_hitbox.monitorable = true
		print(player_hitbox.monitorable)
	
func _on_animation_finished():
	if (player_sprite.animation == "Punch"):
		doing_action = false
		boxing_glove.position.x = 4
		boxing_glove.visible = false
		player_hitbox.monitorable = false
		print(player_hitbox.monitorable)

func take_damage(amount: int) -> void:
	print("AHHHHHHH: ", amount)
