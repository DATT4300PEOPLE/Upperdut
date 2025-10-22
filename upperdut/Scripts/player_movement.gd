extends CharacterBody2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: player_hitbox = $PlayerSprite/BoxingGlove/player_hitbox
@onready var player_hurtbox: player_hurtbox = $player_hurtbox

# MAKE FIST OBJECT monitoring AND MOVE FORWARD UPON PUNCHING
@onready var boxing_glove: AnimatedSprite2D = $PlayerSprite/BoxingGlove
@export var defaultSpeed = 670
@export var jump_power: float # HAS TO BE NEGATIVE (FORGOT) ALSO ADJUSTABLE BY GLOBAL
@export var player_damage = 4
@export var PLAYER: PLAYER_TYPE
@export var anim_sheet: SpriteFrames
@export var glove_sprite: SpriteFrames
@export var base_knockback_velocity: Vector2
@export var max_action_duration: int

var knockback_timer = 0.0
var knockback_duration = 0.3 # seconds
var is_knocked_back = false
var punch_multiplier = 1
var action_timer = 0


var move_dir = 0
var direction
var jumpKey
var punchDir: String
var currentSpeed: float
var currentAccel: float
var doing_action = false
var punching = false
var gloveX = 55
var gloveY = 44
var gloveRot = -90
enum PLAYER_TYPE {P1,P2}

func _ready() -> void:
	currentSpeed = defaultSpeed
	player_sprite.animation_finished.connect(_on_animation_finished)
	player_sprite.sprite_frames = anim_sheet
	boxing_glove.sprite_frames = glove_sprite
	player_hitbox.knockback_velocity = base_knockback_velocity

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
	if is_knocked_back:
		velocity = velocity.lerp(Vector2.ZERO, delta * 5) #Makes descent smoother, before player would stop on a dime
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0.0 or velocity.length() < 10:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return
	if velocity.x == 0 and is_on_floor() and !doing_action:
		player_sprite.play("Idle")
		move_dir = 0
	
	if punching:
		if action_timer < max_action_duration:
			action_timer += delta
		else:
			action_timer = max_action_duration
	get_input()
	punch_anim_dir()
	
	move_and_slide()
	
# Player uses their mobility by moving around, getting hit increases their mobility
func get_input():
	if PLAYER == 0:
		player_hitbox.player_ID = "P1"
		player_hurtbox.player_ID = "P1"
		direction = Input.get_axis("P1Left", "P1Right")
		jumpKey = "P1Jump"
	else:
		player_hitbox.player_ID = "P2"
		player_hurtbox.player_ID = "P2"
		direction = Input.get_axis("P2Left", "P2Right")
		jumpKey = "P2Jump"
	if direction:
		if direction != 0:
			if !doing_action:
				if direction < 0:
					move_dir = 1 # Moving left
					player_sprite.scale.x = -0.49 # DON'T HARDCODE THIS IN, FIX LATER
				else:
					player_sprite.scale.x = 0.49 # DON'T HARDCODE THIS IN, FIX LATER
					move_dir = 2 # Moving right
				player_sprite.play("Walk")
			velocity.x = direction * (currentSpeed + PlayerData.apply_movement(PLAYER, 1))
	else:
		velocity.x = 0
	get_fight_input(direction)
	if Input.is_action_just_pressed(jumpKey) and is_on_floor():
		move_dir = 3 # Moving up (jumping)
		player_sprite.play("Jump")
		velocity.y = jump_power - PlayerData.apply_movement(PLAYER, 2)
		print("Y VELOCITY: ", velocity.y)
	if Input.is_action_just_released(jumpKey) and is_on_floor():
		move_dir = 3 # Moving up (jumping)
		player_sprite.play("Jump")
		velocity.y = (jump_power - PlayerData.apply_movement(PLAYER, 2)) / 2 

func get_fight_input(direction: int):
	var punchBtn
	var parryBtn
	if PLAYER == 0:
		punchBtn = "P1Punch"
		parryBtn = "P1Parry"
	else:
		punchBtn = "P2Punch"
		parryBtn = "P2Parry"
		#await get_tree().process_frame
	if Input.is_action_pressed(punchBtn):
		player_hitbox.damage = player_damage # ALSO DON"T HARDCODE THIS IN<
		player_hitbox.knockback_velocity = base_knockback_velocity
		punching = true
		player_sprite.play(punchDir)
		doing_action = true
		boxing_glove.visible = true
		boxing_glove.position.x = gloveX
		boxing_glove.position.y = gloveY
		boxing_glove.rotation_degrees= gloveRot
		player_hitbox.monitorable = true
		player_hitbox.monitoring = true
		print(punchDir)
		punching = false
		action_timer = 0
		player_hitbox.damage *= punch_multiplier
		if (PLAYER == 0):
			player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P2_Damage / 50
			player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P2_Damage / 50
		if (PLAYER == 1):
			player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P1_Damage / 50
			player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P1_Damage / 50
		punch_multiplier = action_timer / 0.4
		if (punch_multiplier < 1):
			punch_multiplier = 1	
		print(punch_multiplier)
	if Input.is_action_just_pressed(parryBtn):
		player_sprite.play("Block")
		doing_action = true
	if Input.is_action_just_released(parryBtn):
		doing_action = false

		


func punch_anim_dir():
	if move_dir <= 2:
		punchDir = "Punch"
		gloveX = 173.386
		gloveY = 44.876
		gloveRot = -90
	if move_dir == 3:
		punchDir = "PunchUp"
		gloveX = 77.514
		gloveY = -179.506
		gloveRot = -180
	if move_dir == 4:
		punchDir = "PunchDown"
		
func _on_animation_finished():
	if player_sprite.animation == punchDir:
		doing_action = false
		boxing_glove.position.x = 4
		boxing_glove.visible = false
		player_hitbox.monitorable = false
		player_hitbox.monitoring = false
		player_sprite.play("Idle")
	

					
func take_damage(amount: float, attacker_pos: Vector2, knockback_velocity: Vector2) -> void:
	print("AHHHHHHH: ", knockback_velocity )
	print("Multiplier: ", punch_multiplier)
	is_knocked_back = true
	knockback_timer = knockback_duration

	var knock_dir = sign(global_position.x - attacker_pos.x)

	velocity = Vector2(knockback_velocity.x * knock_dir, knockback_velocity.y)
	PlayerData.apply_damage(amount, PLAYER)



func _on_ladde_area_entered(area: Area2D) -> void:
	print("HELLLOOO")
	print(area.get_parent().name)
