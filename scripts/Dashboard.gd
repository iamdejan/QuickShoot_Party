extends Node2D

func _ready():
	$UserIDLabel.text += " " + String(Session.user_data["id"])
	$UserNameLabel.text += " " + String(Session.user_data["name"])
	pass

func _on_CreateRoomButton_pressed():
	#API Call will be implemented later
	
	get_tree().change_scene(Session.build_scene_URL("Game"))
	pass

func _on_JoinRoomButton_pressed():
	#API Call will be implemented later
	
	get_tree().change_scene(Session.build_scene_URL("JoinRoom"))
	pass


func _on_LogoutButton_pressed():
	Session.flush()
	get_tree().change_scene(Session.build_scene_URL("Home"))
	pass
