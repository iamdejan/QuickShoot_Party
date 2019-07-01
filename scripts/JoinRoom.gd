extends Node2D

func _on_JoinRoomButton_pressed():
	#API Call will be implemented later
	
	get_tree().change_scene(Session.build_scene_URL("Game"))
	pass