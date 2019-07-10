extends Node2D

var player_counter: int = 0
var room_data: Dictionary
var maximum_capacity: int
var last_id: int = -1

var start_time: float
var end_time: float

var is_shoot: bool = false

func reset_room():
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
	
	room_data = Session.data["Game"]
	maximum_capacity = Session.data["maximum_capacity"]
	Session.empty_data()
	
	reset_room()
	get_notifs()
	
	pass

func handle_notifs(notifications: Array):
	for notif in notifications:
		match notif["Type"]:
			"MEMBER_JOIN":
				var node_name = "Player" + String(player_counter) + "Label"
				var player_name = notif["Payload"]["Name"]
				get_node(node_name).text = player_name + " time: ...s"
				player_counter += 1
			"GAME_BEGIN":
				set_process(true)
				$CountdownTimer.start(5.0)
		pass

func _on_NotifHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200 and is_processing() != true:
		var json = JSON.parse(body.get_string_from_utf8())
		var data: Dictionary = json.result
		handle_notifs(data["Notifications"])
		last_id = int(data["LastID"])
		get_notifs()
	elif response_code != 200:
		$MainLabel.text = "Oops!"
	pass

func _process(delta):
	$MainLabel.text = "You have "
	$MainLabel.text += String(ceil($CountdownTimer.time_left))
	$MainLabel.text += " s"

func _on_CountdownTimer_timeout():
	is_shoot = false
	start_time = OS.get_system_time_msecs() / 1000.0
	$MainLabel.text = "TAP!"
	$CountdownTimer.stop()
	set_process(false)
	pass

func _input(event):
	if event.is_action("shoot") or event is InputEventScreenTouch:
		if is_shoot != true:
			end_time = OS.get_system_time_msecs() / 1000.0
			var duration: float = end_time - start_time
			$MainLabel.text = String(duration)
			is_shoot = true
		pass