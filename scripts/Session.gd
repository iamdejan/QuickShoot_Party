extends Node

const prefix = "res://scenes/"
const extension = "tscn"

static func build_scene_URL(key) -> String:
	return prefix + key + "." + extension