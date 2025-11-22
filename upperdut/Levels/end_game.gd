extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.owner.name == "Player 1" or area.owner.name == "Player 2":
		get_tree().change_scene_to_file("res://main_menu.tscn")
