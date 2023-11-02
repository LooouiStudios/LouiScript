extends Control

signal finished()

func _input(event):
	if Input.is_action_just_pressed("enter"):
		emit_signal("finished")
