extends Node
class_name Token

var type = null
var value = null

func _init(type_, value_ = null):
	type = type_
	value = value_

func get_str():
	return str(type) + ": " + str(value)
