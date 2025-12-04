extends Node2D

@onready var punch: AudioStreamPlayer = $Punch
@onready var jump: AudioStreamPlayer = $Jump
@onready var stock_loss: AudioStreamPlayer = $StockLoss

func play_punch() -> void:
	punch.play()
func play_jump() -> void:
	jump.play()
func play_stock_loss() -> void:
	stock_loss.play()
