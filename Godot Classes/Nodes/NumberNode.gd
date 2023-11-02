extends Node
class_name NumberNode

var token

func _init(token_):
	token = token_

func get_str():
	return str(token.value)
