class_name player_hurtbox
extends Area2D

# Whenever hurtbox enters hitbox, player takes damage
 
@export var damage := 5
@export var player_ID: String

func _init() -> void:
	collision_layer = 0
	collision_mask = 3
	
func _ready() -> void: 
	area_entered.connect(Callable(self,"_on_area_entered"))
	
func _on_area_entered(hitbox: player_hitbox) -> void: # ADD KNOCKBACK EFFECT TO PUNCH
	if hitbox == null:
		return
	if owner.has_method("take_damage") and hitbox.player_ID != self.player_ID:
		var attacker_global_pos = hitbox.global_position
		owner.take_damage(hitbox.damage, attacker_global_pos, hitbox.knockback_velocity)
