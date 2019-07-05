extends Node2D

func _ready():
	$SubmitButton.disabled = false
	pass

func _on_SubmitButton_pressed():
	$SubmitButton.disabled = true
	Session.register($RegisterText.text)
	pass


func _on_GoBackButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Home"))
	pass
