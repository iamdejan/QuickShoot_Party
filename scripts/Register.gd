extends Node2D

func _on_RegisterButton_pressed():
	#API Call will be implemented later
	
	get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	pass