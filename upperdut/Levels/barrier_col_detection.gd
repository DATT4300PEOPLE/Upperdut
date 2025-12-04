extends Area2D
@onready var barrier_collider: CollisionShape2D = $StageBarrier/barrier_collider
@onready var invisible_barrier: ColorRect = $StageBarrier/InvisibleBarrier

var player_list = []
var barrier_on = false

func _physics_process(delta: float) -> void:
	if player_list.size() >= 2:
		barrier_on = true
		invisible_barrier.visible = true
		barrier_collider.disabled = false
		
func _on_area_entered(area: Area2D) -> void:
	if area.owner.name == "Player 1":
		if player_list.has("Player 1"):
			player_list.remove_at(player_list.find("Player 1"))
		else:
			player_list.append("Player 1")
	print(player_list)
	if area.owner.name == "Player 2":
		if player_list.has("Player 2"):
			player_list.remove_at(player_list.find("Player 2"))
		else:
			player_list.append("Player 2")
	print(player_list)
