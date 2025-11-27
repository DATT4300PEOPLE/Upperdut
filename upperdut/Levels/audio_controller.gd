extends Node2D

@onready var punch: AudioStreamPlayer = $Punch
@onready var jump: AudioStreamPlayer = $Jump


func play_punch() -> void:
	punch.play()
func play_jump() -> void:
	jump.play()
