extends Area2D

@export var BELT: BELT_SIDE
enum BELT_SIDE {RED,BLUE}

func _on_area_entered(area: Area2D) -> void:
	if area.owner.name == "Player 1" and BELT == 0:
		PlayerData.Belt_Pieces.append(self)
		self.visible = false
		self.monitorable = false
		self.monitoring = false
	if area.owner.name == "Player 2" and BELT == 1:
		PlayerData.Belt_Pieces.append(self)
		self.visible = false
		self.monitorable = false
		self.monitoring = false
