extends Node

const prefix = "res://scenes/"
const extension = "tscn"
const scene_URL = {
	"Game": "Game",
	"Login": "Login",
	"Register": "Register",
	"Room": "Room",
	"Home": "Home",
	"Dashboard": "Dashboard"
}

static func build_scene_URL(key) -> String:
	return prefix + scene_URL[key] + "." + extension