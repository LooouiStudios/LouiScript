extends Control

@onready var code_edit = get_node("CodeEdit")
@onready var console = get_node("Console")
var token_lines : Array = []
var last_used_label = null

var active_variables : Dictionary = {}
var ifs_passed = [0]

func _on_start_pressed():
	run_program()

func add_to_console(text : String, print = false):
	var label = console.print_console(text)
	if print:
		last_used_label = label

func run_program():
	ifs_passed = [0]
	
	console.show()
	for child in console.vbox.get_children():
		if child.name != "Label":
			child.queue_free()
	
	for i in 10:
		print()
	print("Starting program ------------------------------- " + Time.get_time_string_from_system())
	
	var lines = code_edit.text.split("\n")
	
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
				print("pattern matched! ", pattern)
				var pattern_str = Constants.TOKEN_PATTERNS.find_key(pattern)
				var pattern_operator = PatternOperator.new(pattern_str, tokens, self)
				await pattern_operator.create_output() == "success"
	
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
