extends Area2D


func _on_area_entered(area: Area2D) -> void:
	print(area.get_parent().name)
	if area.get_parent().name == "Player 1":
		PlayerData.P1_onLadder = true
	else:
		PlayerData.P2_onLadder = true


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Player 1":
		PlayerData.P1_onLadder = false
	else:
		PlayerData.P2_onLadder = false
