class_name player_hurtbox
extends Area2D


@export var damage := 5

func _init() -> void:
	collision_layer = 0
	collision_mask = 3
	
func _ready() -> void: 
	area_entered.connect(Callable(self,"_on_area_entered"))
	
func _on_area_entered(hitbox: player_hitbox) -> void: # ADD KNOCKBACK EFFECT TO PUNCH
	if hitbox == null:
		return
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
