extends CharacterBody2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: player_hitbox = $PlayerSprite/BoxingGlove/player_hitbox
@onready var player_hurtbox: player_hurtbox = $player_hurtbox
@onready var p2: CharacterBody2D = $"../Player 2"
@onready var p1: CharacterBody2D = $"."

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
@export var max_parry_window: float
@export var parry_knockback: Vector2
@export var parry_successful: bool

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
	for ladder in get_tree().get_nodes_in_group("ladder_areas"):
		ladder.connect("area_entered", Callable(self, "_on_ladde_area_entered"))
		ladder.connect("area_exited", Callable(self, "_on_ladde_area_exited"))

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta

	if p1_on_ladder and PLAYER == 0:
		if (Input.is_action_pressed("P1Jump") and PLAYER == 0):
			velocity.y = -defaultSpeed * delta * 50
		elif (Input.is_action_pressed("P1Descend") and PLAYER == 0):
			velocity.y = defaultSpeed * delta * 50
		else:
			velocity.y = 0

	if p2_on_ladder and PLAYER == 1:
		if (Input.is_action_pressed("P2Jump") and PLAYER == 1):
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
	hit_switch()
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
		player_sprite.play("Jump")
		velocity.y = jump_power - PlayerData.apply_movement(PLAYER, 2)
		print("Y VELOCITY: ", velocity.y)

	if Input.is_action_just_released(jumpKey) and is_on_floor():
		move_dir = 3
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

	if Input.is_action_pressed(punchBtn):
		player_hitbox.damage = player_damage
		player_hitbox.knockback_velocity = base_knockback_velocity
		punching = true
		doing_action = true
		
		player_sprite.play("PrePunch")
		punch_multiplier = action_timer / 0.4
		if (punch_multiplier < 1):
			punch_multiplier = 1	
		print(punch_multiplier)
	if Input.is_action_just_released(punchBtn):
		boxing_glove.visible = true
		player_sprite.play(punchDir)
		boxing_glove.position.x = gloveX
		boxing_glove.position.y = gloveY
		boxing_glove.rotation_degrees = gloveRot
		player_hitbox.monitorable = true
		player_hitbox.monitoring = true
		punching = false
		action_timer = 0
		player_hitbox.damage *= punch_multiplier
		if (PLAYER == 0):
			player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P2_Damage / 50
			player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P2_Damage / 50
		if (PLAYER == 1):
			player_hitbox.knockback_velocity.x *= punch_multiplier + PlayerData.P1_Damage / 50
			player_hitbox.knockback_velocity.y *= punch_multiplier + PlayerData.P1_Damage / 50

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
		boxing_glove.visible = false
		player_hitbox.monitorable = false
		player_hitbox.monitoring = false
		player_sprite.play("Idle")

func take_damage(amount: float, attacker_pos: Vector2, knockback_velocity: Vector2) -> void:
	print("AHHHHHHH: ", knockback_velocity)
	print("Multiplier: ", punch_multiplier)
	is_knocked_back = true
	knockback_timer = knockback_duration

	var knock_dir = sign(global_position.x - attacker_pos.x)

	if isParrying:
		if PLAYER == 0:
			p2.parry_successful = true
			p2.knockback_timer = knockback_duration
			p2.velocity = Vector2((knockback_velocity.x + parry_knockback.x) * -knock_dir, knockback_velocity.y + parry_knockback.y)
			print("DIRECTION: ", p2.velocity)
		else:
			p1.parry_successful = true
			p2.knockback_timer = knockback_duration
			p1.velocity = Vector2((knockback_velocity.x + parry_knockback.x) * -knock_dir, knockback_velocity.y + parry_knockback.y)

	velocity = Vector2(knockback_velocity.x * knock_dir, knockback_velocity.y)
	PlayerData.apply_damage(amount, PLAYER)

func _on_ladde_area_entered(area: Area2D) -> void:
	print(area.name)
	if "player_collider" in area.name:
		if PLAYER == 0:
			p1_on_ladder = true
		else:
			p2_on_ladder = true
		print("LADDER STUFF: ", p1_on_ladder ,", " , p2_on_ladder)

func _on_ladde_area_exited(area: Area2D) -> void:
		if "player_collider" in area.name:
			if PLAYER == 0:
				p1_on_ladder = false
			else:
				p2_on_ladder = false
func _on_switch_area_entered(area: Area2D) -> void:
	if "player_collider" in area.name:
		print(area.name)
		near_switch = true

func _on_switch_area_exited(area: Area2D) -> void:
	if "player_collider" in area.name:
		near_switch = false

func hit_switch() -> void:
	if near_switch == true and Input.is_action_pressed("P1Punch") || near_switch == true and Input.is_action_pressed("P2Punch"):
		print("works")
		switch_hit == true
		
func use_powerup(powerup_type: String) -> void:
	match powerup_type:
		"speed":
			currentSpeed += 300
		"jump":
			jump_power -= 200
		"punch":
			player_damage += 6
