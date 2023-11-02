extends Node
class_name Error

var error_name
var error_details

func _init(n, d):
	error_name = n
	error_details = d
	Constants.main.add_to_console(get_str())
	print(get_str())

func get_str():
	var string = "Error! " + error_name + ": " + error_details + " at line: " + str(Constants.current_line)
	return string
