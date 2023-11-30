extends Node
class_name Token

var type = null
var value = null
var tabs = 0
var variable_name = ""

func _init(text_, type_, value_ = null, variable_name_ = ""):
	type = type_
	value = value_
	tabs = text_.count("	")
	variable_name = variable_name_
	if variable_name != "":
		print("Variable name: ", variable_name)

func get_str():
	return str(type) + ": " + str(value) + ", tabs: " + str(tabs)
