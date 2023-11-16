# Color pallete: Base2Tone
extends CodeEdit

@onready var console_vbox = get_node("../Console/ScrollContainer/VBoxContainer")

var variables = []
var past_variables = []

var colors = {
	"bg_purple": Color("2a2734"), # <- Background
	"gray_purple": Color("595a75"), # <- Side numbers and comments
	"light_orange": Color("fcdaab"), # <- Strings
	"orange": Color("fb954b"), # <- if, +, -, *, /, while, for, numbers, func
	"light_purple": Color("c49aa9"), # <- Types (int, float, string, array, dictionary), functions
	"dark_purple": Color("b197fe") # <- Variable names
}

var keywords = {
	"int": "light_purple",
	"float": "light_purple",
	"string": "light_purple",
	"array": "light_purple", 
	"dictionary": "light_purple",
	"func": "orange",
	"for": "orange",
	"while": "orange",
	"true": "dark_purple",
	"false": "dark_purple",
	"bool": "light_purple",
	"pass": "orange",
	"if": "dark_purple",
	"else": "dark_purple"
}

@onready var auto_completion_keywords = [
	"int", "float", "string", "array", "bool", "true", "false",
	"print", "printc", "input", "make_int", "make_float", "make_string",
	"add", "subtract", "multiply", "divide", "if"
] 

var font_size = 38
var old_text = ""

func _ready():
	for keyword in keywords.keys():
		syntax_highlighter.keyword_colors[keyword] = colors[keywords[keyword]]
	
	syntax_highlighter.add_color_region('"', '"', colors["light_orange"])
	syntax_highlighter.add_color_region("@", ",", colors["dark_purple"])
	syntax_highlighter.add_color_region("<<", ">>", colors["gray_purple"])
	syntax_highlighter.add_color_region("{", "}", colors["gray_purple"])
	
	add_theme_font_size_override("font_size", font_size)
	for child in console_vbox.get_children():
		child.add_theme_font_size_override("font_size", font_size - 15)

func _input(_event):
	if Input.is_action_pressed("ctrl"):
		if Input.is_action_pressed("scroll_wheel_up"):
			font_size += 1
		
		elif Input.is_action_pressed("scroll_wheel_down"):
			font_size -= 1
		
		font_size = clamp(font_size, 8, 60)
	
	add_theme_font_size_override("font_size", font_size)
	for child in console_vbox.get_children():
		child.add_theme_font_size_override("font_size", font_size - 15)

func _process(delta):
	if text != old_text:
		old_text = text
		variables.clear()
		if text.find("@") == -1: return
		var split_text = text.split("@")
		for split in split_text:
			variables.append(split.split(",")[0])
			past_variables.append(split.split(",")[0])
		
		for variable in variables:
			syntax_highlighter.keyword_colors[variable] = colors["dark_purple"]
		
		for past_variable in past_variables:
			if past_variable not in variables:
				syntax_highlighter.keyword_colors[past_variable] = Color(1,1,1,1)

func _on_text_changed():
	code_completion_enabled = true
	for keyword in auto_completion_keywords:
		add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, keyword, keyword)
	update_code_completion_options(false)
	#print(get_code_completion_options())
