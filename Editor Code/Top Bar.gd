extends Control


func _on_save_pressed():
	get_node("../CodeEdit").save()