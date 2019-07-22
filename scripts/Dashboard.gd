extends Node2D

func _ready():
	$UserIDLabel.text += " " + String(Session.user_data["id"])
	$UserNameLabel.text += " " + String(Session.user_data["name"])
	pass

func _on_CreateRoomButton_pressed():
	var maximum_capacity: int = int($RoomCapacity.text)
	Session.data["room"]["maximum_capacity"] = maximum_capacity
	var data: Dictionary = {
		"Payload": {
			"MaxMemberCount": maximum_capacity
		}
	}
	var json_sent = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	
	$HTTPRequest.request(Session.URL + "/room/new",
						 headers,
						 false,
						 HTTPClient.METHOD_POST,
						 json_sent)
	
	pass

func _on_JoinRoomButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("JoinRoom"))
	pass


func _on_LogoutButton_pressed():
	Session.flush()
	get_tree().change_scene(Session.build_scene_URL("Home"))
	pass

func self_join():
	var room_data: Dictionary = Session.data["room"]
	var maximum_capacity = room_data["maximum_capacity"]
	
	var data = {
		"Payload": {
			"ID": Session.user_data["id"],
			"Name": Session.user_data["name"]
		}
	}
	
	var json_sent = JSON.print(data)
	
	var headers = ["Content-Type: application/json"]
	$JoinHTTPRequest.request(Session.URL + "/room/" + String(room_data["ID"]) + "/member/new",
						headers,
						false,
						HTTPClient.METHOD_POST,
						json_sent)
	
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var data: Dictionary = json.result
		Session.data["room"]["ID"] = data["ID"]
		self_join()
	pass

func _on_JoinHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		get_tree().change_scene(Session.build_scene_URL("Game"))
	pass
