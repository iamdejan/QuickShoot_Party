extends Node2D

var player_counter: int = 0
var last_id: int = -1
var user_ids: Array = []
var game_ends: bool = false
var is_shoot: bool = false

var room_data: Dictionary
var maximum_capacity: int
var start_time: float = -1.0
var end_time: float

func reset_room():
	$RoomIDLabel.text = "Room ID: " + String(room_data["ID"])
	for i in range(4):
		get_node("Player" + String(i) + "Label").text = ""
	pass

func get_notifs():
	var notif_url = Session.URL + "/room/" + String(room_data["ID"]) + "/events?lastID=" + String(last_id)
	var headers = ["Content-Type: application/json"]
	$NotifHTTPRequest.request(notif_url, headers, false)
	pass

func _ready():
	set_process(false)
	$MainLabel.text = "Waiting..."
	
	room_data = Session.data["room"]
	maximum_capacity = room_data["maximum_capacity"]
	Session.empty_data()
	
	reset_room()
	get_notifs()
	
	pass

func handle_notifs(notifications: Array):
	for notif in notifications:
		var payload: Dictionary
		if(notif.has("Payload")):
			payload = notif["Payload"]
		match notif["Type"]:
			"MEMBER_JOIN":
				var node_name = "Player" + String(player_counter) + "Label"
				var player_name = payload["Name"]
				get_node(node_name).text = player_name
				user_ids.append(int(payload["ID"]))
				player_counter += 1
			"MEMBER_LEAVE":
				var player_index = user_ids.find(int(payload["MemberID"]))
				for i in range(player_index, player_counter):
					var node_name = "Player" + String(i) + "Label"
					get_node(node_name).text = get_node("Player" + String((i + 1)) + "Label").text
				player_counter -= 1
				get_node("Player" + String(player_counter) + "Label").text = ""
			"GAME_BEGIN":
				$LeaveButton.disabled = true
				set_process(true)
				$CountdownTimer.start(5.0)
			"MEMBER_TAP_TIME":
				var player_index = user_ids.find(int(payload["MemberID"]))
				var node_name = "Player" + String(player_index) + "Label"
				get_node(node_name).text += "\nTime: " + String((payload["TapTime"] / 1000.0)) + " s"
			"GAME_END":
				game_ends = true
				var winner: Dictionary = payload["Winner"]
				if Session.user_data["id"] == winner["ID"]:
					$MainLabel.text = "You WIN!"
				else:
					$MainLabel.text = "You LOSE!"
				
				$LeaveButton.text = "Go Back"
				$LeaveButton.disabled = false
		pass

func _on_NotifHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200 and is_processing() != true:
		var json = JSON.parse(body.get_string_from_utf8())
		var data: Dictionary = json.result
		handle_notifs(data["Notifications"])
		last_id = int(data["LastID"])
		if game_ends != true:
			get_notifs()
	elif response_code != 200:
		$MainLabel.text = "Oops! Status " + String(response_code)
	pass

func _process(delta):
	$MainLabel.text = "You have "
	$MainLabel.text += String(ceil($CountdownTimer.time_left))
	$MainLabel.text += " s"

func _on_CountdownTimer_timeout():
	is_shoot = false
	$MainLabel.text = "TAP!"
	$CountdownTimer.stop()
	set_process(false)
	start_time = OS.get_system_time_msecs() / 1000.0
	pass

func _input(event):
	if start_time >= 0.0 and $CountdownTimer.time_left <= 0.0 and (event.is_action("shoot") or event is InputEventScreenTouch):
		if is_shoot != true:
			end_time = OS.get_system_time_msecs() / 1000.0
			var duration: float = end_time - start_time
			$MainLabel.text = String(duration)
			is_shoot = true
			
			# TODO: Register shoot time
			var data = {
				"Payload": {
					"TimeInMilis": int(round(duration * 1000))
				}
			}
			var json_sent = JSON.print(data)
			var headers = ["Content-Type: application/json"] 
			$ShootHTTPRequest.request(Session.URL + "/room/" + String(room_data["ID"]) + "/member/" + String(Session.user_data["id"]) + "/tap",
									  headers,false,HTTPClient.METHOD_POST,json_sent)
			
		pass

func _on_LeaveButton_pressed():
	$LeaveButton.disabled = true
	if game_ends != true:
		$LeaveHTTPRequest.request(Session.URL + "/room/" + String(room_data["ID"]) + "/member/" + String(Session.user_data["id"]),
						  		  [],
								  false,
								  HTTPClient.METHOD_DELETE)
	else:
		get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	pass

func _on_LeaveHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	else:
		$LeaveButton.disabled = false
	pass


func _on_ShootHTTPRequest_request_completed(result, response_code, headers, body):
	get_notifs()
	pass
