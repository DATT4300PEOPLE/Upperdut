extends Area2D
@onready var switch: AudioStreamPlayer = $"../AudioController/Switch"
@onready var timerText: RichTextLabel = $TimerText

@export var platform: StaticBody2D
@export var switch_id: int
@export var max_duration: float
@export var button: bool
@export var switchOff: bool
@export var playerSwitch: int
var player1_on_switch = false
var player2_on_switch = false
var button_image: Sprite2D
var switchOn = false
var onTimer = 0
func _ready() -> void:
	max_duration = 2
	area_entered.connect(Callable(self,"_on_area_entered"))
	area_exited.connect(Callable(self,"_on_area_exited"))
	button_image = self.get_child(1)
func _process(delta: float) -> void:
	if player1_on_switch and Input.is_action_just_pressed("P1Punch") and not switchOn and not button and playerSwitch == 0:
		print("works")
		turn_switch_on()
	if player2_on_switch and Input.is_action_just_pressed("P2Punch") and not switchOn and not button and playerSwitch == 1:
		print("p2 WORKS")
		turn_switch_on()
	if (player1_on_switch or player2_on_switch) and button:
		toggle_button()
	elif ( not player1_on_switch and not player2_on_switch) and button and switchOn:
		switchOn = false
		button_image.texture = load("res://Assets/button-off.png")
		platform.visible = false
		platform.get_child(1).disabled = true
	if switchOn and onTimer < max_duration and not button:
		onTimer += 1 * delta
	if onTimer >= max_duration and not button:
		switchOn = false
		if switchOff:
			platform.visible = true
			platform.get_child(1).disabled = false
		else:
			platform.visible = false
			platform.get_child(1).disabled = true
		if !button:
			button_image.texture = load("res://Sprites/switch-off.png")
			await get_tree().create_timer(0.4).timeout
			button_image.texture = load("res://Sprites/switch-none.png")
		onTimer = 0
	if onTimer > 0:
		timerText.visible = true
		timerText.text = str(snapped(max_duration - onTimer,0.01))
	if onTimer <= 0 and timerText:
		timerText.visible = false
		
func turn_switch_on() -> void:
	switchOn = true
	switch.play()
	button_image.texture = load("res://Sprites/switch-on.png")
	if switchOff:
		platform.visible = false
		platform.get_child(1).disabled = true
	else:
		platform.visible = true
		platform.get_child(1).disabled = false

func toggle_button() -> void:
	switchOn = true
	button_image.texture = load("res://Assets/button-on.png")
	platform.visible = true
	platform.get_child(1).disabled = false
func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Player 1":
		player1_on_switch = true
	elif area.get_parent().name == "Player 2":
		player2_on_switch = true

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Player 1":
		player1_on_switch = false
	elif area.get_parent().name == "Player 2":
		player2_on_switch = false
