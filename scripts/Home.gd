extends Node2D

func _on_LoginButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Login"))
	pass


func _on_RegisterButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Register"))
	pass
