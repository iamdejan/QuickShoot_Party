extends Node2D

func _on_JoinRoomButton_pressed():
	var data: Dictionary = {
		"Payload": {
			"ID": int(Session.user_data["id"]),
			"Name": Session.user_data["name"]
		}
	}
	var json_sent = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	
	$HTTPRequest.request(Session.URL + "/room/" + $RoomIDText.text + "/member/new",
						 headers, 
						 false,
						 HTTPClient.METHOD_POST,
						 json_sent)
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		Session.data["Game"] = {
			"ID": int($RoomIDText.text)
		}
		var json = JSON.parse(body.get_string_from_utf8())
		var data: Dictionary = json.result
		Session.data["maximum_capacity"] = data["MaxMemberCount"]
		get_tree().change_scene(Session.build_scene_URL("Game"))
	pass
