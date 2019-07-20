extends Node

const prefix: String = "res://scenes/"
const extension: String = "tscn"

const URL = "http://localhost:8080"
#const URL = "http://quickshoot-party-match-server.herokuapp.com"

func build_scene_URL(key) -> String:
	return prefix + key + "." + extension

const user_data = {
	"name": "",
	"id": -1
}

var data: Dictionary = {}

func empty_data():
	data.clear()
	pass

var scene_source: String = ""

func login(user_id: String) -> void:
	scene_source = "Login"
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("http://quickshoot-party-data-server.herokuapp.com/users/" + user_id, headers)
	pass

func register(name: String) -> void:
	scene_source = "Register"
	
	var data = {
		"name" : name
	}
	
	var json_sent = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	
	$HTTPRequest.request("http://quickshoot-party-data-server.herokuapp.com/users/create", headers, true, HTTPClient.METHOD_POST, json_sent)
	pass

func set_user_data(user: Dictionary) -> void:
	user_data["name"] = user["name"]
	user_data["id"] = int(user["id"])
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json
	var data: Dictionary
	var user: Dictionary
	if result == $HTTPRequest.RESULT_SUCCESS and body.size() > 0:
		json = JSON.parse(body.get_string_from_utf8())
		data = json.result
		if data["success"] == true:
			user = data["result"]
			set_user_data(user)
			get_tree().change_scene(Session.build_scene_URL("Dashboard"))
		else:
			get_tree().get_root().get_node("/root/" + scene_source + "/SubmitButton").disabled = false
			get_tree().get_root().get_node("/root/" + scene_source + "/ErrorLabel").text = data.message
	pass

func flush() -> void:
	user_data["name"] = ""
	user_data["id"] = -1
	pass