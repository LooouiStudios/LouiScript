extends Control

@onready var vbox = get_node("ScrollContainer/VBoxContainer")
@onready var origin_label = get_node("ScrollContainer/VBoxContainer/Label")

func print_console(text : String):
	var label = origin_label.duplicate()
	label.show()
	label.text = "    " + str(Time.get_time_string_from_system()) + ": " + text
	vbox.add_child(label)
	return label


func _on_console_toggle_pressed():
	visible = !visible
