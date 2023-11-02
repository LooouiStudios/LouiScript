extends Node
class_name Token

var type = null
var value = null
var tabs = 0

func _init(text_, type_, value_ = null):
	type = type_
	value = value_
	tabs = text_.count("	")

func get_str():
	return str(type) + ": " + str(value) + ", tabs: " + str(tabs)
