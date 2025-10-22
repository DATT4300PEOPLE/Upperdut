extends Node2D
@onready var screen_right: Area2D = $ScreenRight
@onready var screen_left: Area2D = $ScreenLeft


func _ready() -> void: 
	area_entered.connect(Callable(self,"_on_area_entered"))
	
func _on_area_entered(area: Area2D) -> void:
	print(owner.name)
