extends Node2D
@onready var p1_label: Label = $P1Label
@onready var p2_label: Label = $P2Label

func _process(delta: float) -> void:
	p1_label.text = str(PlayerData.P1_Damage)
	p2_label.text = str(PlayerData.P2_Damage)
