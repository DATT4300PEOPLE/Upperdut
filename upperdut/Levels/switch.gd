extends Area2D

@export var platform: StaticBody2D
@export var switch_id: int
@export var max_duration: float
@export var button: bool
var player1_on_switch = false
var player2_on_switch = false
var button_image: Sprite2D
var switchOn = false
var onTimer = 0
func _ready() -> void:
	max_duration = 1.4
	area_entered.connect(Callable(self,"_on_area_entered"))
	area_exited.connect(Callable(self,"_on_area_exited"))
	button_image = self.get_child(1)
func _process(delta: float) -> void:
	if player1_on_switch and Input.is_action_just_pressed("P1Punch") and not switchOn and not button:
		print("works")
		turn_switch_on()
	if player2_on_switch and Input.is_action_just_pressed("P2Punch") and not switchOn and not button:
		print("p2 WORKS")
		turn_switch_on()
##	if player1_on_switch or player2_on_switch:
		##toggle_button()
	if switchOn and onTimer < max_duration:
		onTimer += 1 * delta
	if onTimer >= max_duration and not button:
		switchOn = false
		platform.visible = !platform.visible
		if !button:
			button_image.texture = load("res://Sprites/switch-off.png")
			await get_tree().create_timer(0.4).timeout
			button_image.texture = load("res://Sprites/switch-none.png")
		onTimer = 0
		platform.get_child(1).disabled = !platform.get_child(1).disabled
func turn_switch_on() -> void:
	switchOn = true
	if button:
		button_image.texture = load("res://Assets/button-on.png")
	else:
		button_image.texture = load("res://Sprites/switch-on.png")
	platform.visible = !platform.visible
	platform.get_child(1).disabled = !platform.get_child(1).disabled

##func toggle_button() -> void:


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
