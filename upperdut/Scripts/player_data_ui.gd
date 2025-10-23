extends Node2D
@onready var meterP1: TextureProgressBar = $MeterP1
@onready var meterP2: TextureProgressBar = $MeterP2

func _process(delta: float) -> void:
	meterP1.value = lerp(meterP1.value, PlayerData.P1_Damage, 0.1)
	meterP2.value = lerp(meterP2.value, PlayerData.P2_Damage, 0.1)
