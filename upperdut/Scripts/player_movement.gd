extends CharacterBody2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: player_hitbox = $PlayerSprite/BoxingGlove/player_hitbox
@onready var player_hurtbox: player_hurtbox = $player_hurtbox

@onready var punch: AudioStreamPlayer = $"../AudioController/Punch"
@onready var jump: AudioStreamPlayer = $"../AudioController/Jump"

# MAKE FIST OBJECT monitoring AND MOVE FORWARD UPON PUNCHING
# Animations
@onready var boxing_glove: AnimatedSprite2D = $PlayerSprite/BoxingGlove
@onready var charge_anim: GPUParticles2D = $ParticleCharge/GPUParticles2D
@onready var charge_indicator: GPUParticles2D = $ParticleChargeReady/GPUParticles2D
@export var p1: CharacterBody2D
@export var p2: CharacterBody2D
@export var defaultSpeed = 670
@export var jump_power: float # HAS TO BE NEGATIVE (FORGOT) ALSO ADJUSTABLE BY GLOBAL
@export var player_damage = 4
@export var PLAYER: PLAYER_TYPE
@export var anim_sheet: SpriteFrames
@export var glove_sprite: SpriteFrames
@export var base_knockback_velocity: Vector2
@export var max_action_duration: int
@export var max_parry_window: float
@export var parry_knockback: Vector2
@export var parry_successful: bool = false

var knockback_timer = 0.0
var knockback_duration = 0.3 # seconds
var is_knocked_back = false
var punch_multiplier = 1
var action_timer = 0
var parry_timer = 0
var isParrying = false
var p1_on_ladder = false
var p2_on_ladder = false
var near_switch = false
var switch_hit = false

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
	p1_on_ladder = false
	p2_on_ladder = false

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta

	if PlayerData.P1_onLadder and PLAYER == 0:
		if (Input.is_action_pressed("P1Up") and PLAYER == 0):
			velocity.y = -defaultSpeed * delta * 50
		elif (Input.is_action_pressed("P1Descend") and PLAYER == 0):
			velocity.y = defaultSpeed * delta * 50
		else:
			velocity.y = 0

	if PlayerData.P2_onLadder and PLAYER == 1:
		if (Input.is_action_pressed("P2Up") and PLAYER == 1):
			velocity.y = -defaultSpeed * delta * 50
		elif (Input.is_action_pressed("P2Descend") and PLAYER == 1):
			velocity.y = defaultSpeed * delta * 50
		else:
			velocity.y = 0

	if is_knocked_back:
		velocity = velocity.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0.0 or velocity.length() < 10:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return

	if parry_successful:
		velocity = velocity.lerp(Vector2.ZERO, delta * 5)
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0.0 or velocity.length() < 10:
			parry_successful = false
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

	if isParrying && parry_timer < max_parry_window:
		parry_timer += 1 * delta
		if parry_timer >= max_parry_window:
			parry_timer = 0
			doing_action = false
			isParrying = false

	get_input()
	punch_anim_dir()
	move_and_slide()

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
					move_dir = 1
					player_sprite.scale.x = -0.49
				else:
					player_sprite.scale.x = 0.49
					move_dir = 2
				player_sprite.play("Walk")
			velocity.x = direction * (currentSpeed + PlayerData.apply_movement(PLAYER, 1))
	else:
		velocity.x = 0

	get_fight_input(direction)

	if Input.is_action_just_pressed(jumpKey) and is_on_floor():
		move_dir = 3
		doing_action = false
		punching = false
		player_sprite.play("Jump")
		jump.play()
		velocity.y = jump_power - PlayerData.apply_movement(PLAYER, 15, true)
		print("Y VELOCITY: ", velocity.y)

	#if Input.is_action_just_released(jumpKey) and is_on_floor(): # WAS TO PREVENT B HOPPING, REMOVED
		#move_dir = 3
		#doing_action = false
		#punching = false
		#player_sprite.play("Jump")
		#jump.play()
		#velocity.y = (jump_power - PlayerData.apply_movement(PLAYER, 15, true)) / 2 

func get_fight_input(direction: int):
	var punchBtn
	var parryBtn
	if PLAYER == 0:
		punchBtn = "P1Punch"
		parryBtn = "P1Parry"
	else:
		punchBtn = "P2Punch"
		parryBtn = "P2Parry"

	if Input.is_action_pressed(punchBtn):
		player_hitbox.damage = player_damage
		player_hitbox.knockback_velocity = base_knockback_velocity
		punching = true
		doing_action = true
		jump.play()
		player_sprite.play("PrePunch")
		
		punch_multiplier = action_timer / 0.4
		if (punch_multiplier < 1):
			punch_multiplier = 1
		print(punch_multiplier)
		if (punch_multiplier >= 1.1 && punch_multiplier < 4.2): 
			charge_anim.emitting = true #Enable charge animation
		elif (punch_multiplier >= 5): 
			charge_indicator.emitting = true #disable charge animation
			charge_anim.emitting = false 

	if Input.is_action_just_released(punchBtn):
		
		player_sprite.play(punchDir)
		charge_anim.emitting = false #disable charge animation
		boxing_glove.position.x = gloveX
		boxing_glove.position.y = gloveY
		boxing_glove.rotation_degrees = gloveRot
		player_hitbox.monitorable = true
		player_hitbox.monitoring = true
		punching = false
		action_timer = 0
		player_hitbox.damage *= punch_multiplier
		if (PLAYER == 0):
			if not move_dir == 3:
				player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P2_Damage / 50
				player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P2_Damage / 50
			else:
				player_hitbox.knockback_velocity.x *= 0
				player_hitbox.knockback_velocity.y *= punch_multiplier * 1.2 + PlayerData.P2_Damage / 30
		if (PLAYER == 1):
			if not move_dir == 3:
				player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P1_Damage / 50
				player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P1_Damage / 50
			else:
				player_hitbox.knockback_velocity.x *= 0
				player_hitbox.knockback_velocity.y *= punch_multiplier * 1.2 + PlayerData.P1_Damage / 30
	
	if Input.is_action_just_pressed(parryBtn):
		player_sprite.play("Block")
		isParrying = true
		doing_action = true

	if Input.is_action_just_released(parryBtn):
		isParrying = false
		parry_timer = 0
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
		player_hitbox.monitorable = false
		player_hitbox.monitoring = false
		player_sprite.play("Idle")

func take_damage(amount: float, attacker_pos: Vector2, knockback_velocity: Vector2) -> void:
	jump.stop()
	punch.play()
	print("AHHHHHHH: ", knockback_velocity)
	print("Multiplier: ", punch_multiplier)
	is_knocked_back = true
	knockback_timer = knockback_duration

	var knock_dir = sign(global_position.x - attacker_pos.x)
	var player_damage_pct = PlayerData.P1_Damage if PLAYER == 0 else PlayerData.P2_Damage 
	if player_damage_pct < 1:
		player_damage_pct = 1
	if isParrying:
		if PLAYER == 0:
			print("P1 parrying")
			p2.parry_successful = true
			p2.knockback_timer = knockback_duration
			p2.velocity = Vector2((knockback_velocity.x + parry_knockback.x) * -knock_dir, knockback_velocity.y + parry_knockback.y)
			print("DIRECTION: ", p2.velocity)
		if PLAYER == 1:
			print("P2 parrying")
			p1.parry_successful = true
			p1.knockback_timer = knockback_duration
			p1.velocity = Vector2((knockback_velocity.x + parry_knockback.x) * -knock_dir, knockback_velocity.y + parry_knockback.y)
			print("DIRECTION: ", p1.velocity)
	velocity = Vector2(knockback_velocity.x * knock_dir, knockback_velocity.y)
	if !isParrying:
		PlayerData.apply_damage(amount + player_damage_pct/2, PLAYER)

func use_powerup(powerup_type: String) -> void:
	match powerup_type:
		"speed":
			currentSpeed += 300
		"jump":
			jump_power -= 200
		"punch":
			player_damage += 6
