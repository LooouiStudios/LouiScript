extends Control

@onready var code_edit = get_node("CodeEdit")
@onready var console = get_node("Console")

@onready var main_window = get_window()

var token_lines : Array = []
var last_used_label = null

var active_variables : Dictionary = {}
var ifs_passed = [0]
var ifs_not_passed = []
var last_lines = {}
var past_if_result = false

func _ready():
	main_window.gui_embed_subwindows = false

func _on_start_pressed():
	run_program()

func add_to_console(text : String, print = false):
	var label = console.print_console(text)
	if print:
		last_used_label = label

func run_program():
	ifs_passed = [0]
	Constants.current_line = 0
	
	console.show()
	for child in console.vbox.get_children():
		if child.name != "Label":
			child.queue_free()
	
	for i in 10:
		print()
	print("Starting program ------------------------------- " + Time.get_time_string_from_system())
	
	var lines = code_edit.text.split("\n")
	var ifs = 0
	
	for line in lines:
		Constants.current_line += 1
		var token_creator = TokenCreator.new(line, self)
		token_creator.print_tokens()
		var tokens = token_creator.tokens
		
		var pattern = []
		for token in tokens:
			var type = token.type if token.type.to_lower() not in Constants.VALUE_TYPES else "VALUE"
			if token.type in Constants.IF_VALUES:
				type = "IF_OPERATOR"
			pattern.append(type)
		
		if pattern in Constants.TOKEN_PATTERNS.values():
			var remove = []
			for if_passed in ifs_passed:
				if if_passed > tokens[0].tabs:
					remove.append(if_passed)
			
			for delete in remove:
				ifs_passed.remove_at(ifs_passed.find(delete))
			
			if tokens[0].tabs in ifs_passed:
				var pattern_str = Constants.TOKEN_PATTERNS.find_key(pattern)
				print("pattern matched! ", pattern_str)
				var pattern_operator = PatternOperator.new(pattern_str, tokens, self)
				var last_line_on_tab = last_lines[tokens[0].tabs] if tokens[0].tabs in last_lines.keys() else null
				
				if pattern != Constants.TOKEN_PATTERNS["ELSE_STATEMENT"]:
					var previous_if_result = past_if_result
					
					await pattern_operator.create_output() == "success"
					if pattern == Constants.TOKEN_PATTERNS["IF_STATEMENT"]:
						if ifs == 0:
							past_if_result = pattern_operator.if_result
							if pattern_operator.if_result:
								ifs += 1
						else:
							ifs_passed.pop_back()
					elif pattern == Constants.TOKEN_PATTERNS["ELSE_IF_STATEMENT"]:
						if ifs == 0:
							past_if_result = pattern_operator.if_result
							if pattern_operator.if_result:
								ifs += 1
						else:
							ifs_passed.pop_back()
				elif last_line_on_tab[0] in [Constants.TOKEN_PATTERNS["IF_STATEMENT"], Constants.TOKEN_PATTERNS["ELSE_IF_STATEMENT"]]:
					print("IFS ", ifs)
					if ifs == 0:
						ifs_passed.append(tokens[0].tabs + 1)
						await pattern_operator.create_output() == "success"
				else:
					Error.new("ERROR!", "UNKOWN ERROR")
					return
				
				last_lines[tokens[0].tabs] = [pattern, ifs_passed, tokens[0]]
	
	active_variables.clear()
	print("Ending program --------------------------------- " + Time.get_time_string_from_system())
	console.print_console("Program finished --- \n")

func print_tokens(tokens):
	var string = "["
	for token in tokens:
		if token != tokens[0]:
			string += ", "
		string += token.type
		if token.value != null:
			string += ": " + str(token.value)

	print(string + "]")
