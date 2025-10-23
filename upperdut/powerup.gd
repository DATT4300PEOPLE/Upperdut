extends Area2D

@export var sprite_texture: Texture2D
@export var powerup_type: String = "speed" 

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if sprite_texture:
		sprite_2d.texture = sprite_texture
	area_entered.connect(Callable(self,"_on_area_entered"))

func _on_area_entered(hitbox: player_hitbox) -> void:
	print("WORKS")
	if hitbox == null:
		return
	if hitbox.owner.has_method("use_powerup"):
		
		hitbox.owner.use_powerup(powerup_type)
		queue_free()
