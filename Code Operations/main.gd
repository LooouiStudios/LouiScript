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

# While
var while_passed_line = ""
var while_passed_line_tokens = []
var while_passed_line_pattern = []
var while_tab = 0
var while_passed = false
var while_lines = []

# For Loop
var for_loop_line = ""
var for_loop_lines = []
var for_loop_tokens = []
var for_loop_tab = 0
var for_loob_iterable_token = null
var in_for_loop = false

# Function
var functions = {}

func _ready():
	main_window.gui_embed_subwindows = false

func _on_start_pressed():
	run_program(code_edit.text.split("\n"))

func add_to_console(text : String, print_ = false):
	var label = console.print_console(text)
	if print_:
		last_used_label = label

func run_program(lines):
	ifs_passed = [0]
	Constants.current_line = 0

	while_passed_line = ""
	while_passed_line_tokens = []
	while_passed_line_pattern = []
	while_tab = 0
	while_passed = false
	while_lines = []
	
	for_loop_line = ""
	for_loop_lines = []
	for_loop_tokens = []
	for_loop_tab = 0
	for_loob_iterable_token = null
	in_for_loop = false

	console.show()
	for child in console.vbox.get_children():
		if child.name != "Label":
			child.queue_free()
	
	for i in 10:
		print()
	print("Starting program ------------------------------- " + Time.get_time_string_from_system())
	
	var in_function = false
	var function_tab = 0
	var current_func_name = ""
	functions = {}

	for line in lines:
		var token_creator = TokenCreator.new(line, self)
		var tokens = token_creator.tokens
		if !in_function:
			if tokens[0].type == Constants.TOKEN_DEFINE_FUNCTION:
				Constants.IN_BUILT_FUNCTIONS.append(tokens[1].value)
				in_function = true
				function_tab = tokens[0].tabs
				functions[tokens[1].value] = []
				current_func_name = tokens[1].value
		else:
			if function_tab < tokens[0].tabs:
				functions[current_func_name].append(line)
			else:
				in_function = false

	var ifs = 0
	lines.append("")
	for line in lines:
		ifs = await run_line(line, ifs)
	
	active_variables.clear()
	print("Ending program --------------------------------- " + Time.get_time_string_from_system())
	console.print_console("Program finished --- \n")

func run_line(line, ifs, is_recursive=false):
	# line = '@x, int = 0' f.eks.
	if is_recursive:
		Constants.current_line += 1
	var token_creator = TokenCreator.new(line, self)
	var tokens = token_creator.tokens
	print_tokens(tokens)
	
	# region While
	if while_passed and !is_recursive:
		# while_tab = while tokens tab
		if while_tab < tokens[0].tabs:
			while_lines.append(line)
		else:
			var while_max = 0
			while while_passed and while_max < 4096:
				var pattern_operator = PatternOperator.new(while_passed_line_pattern, while_passed_line_tokens, self)
				# x = 0 
				#[0: TOKEN_WHILE, 1: "VALUE", 2: "IF_OPERATOR", 3: "VALUE", 4: TOKEN_END]
				var token1 = while_passed_line_tokens[1]; var token2 = while_passed_line_tokens[3]
				var value1 = token1.value if token1.variable_name == "" else active_variables[token1.variable_name].value
				var value2 = token2.value if token2.variable_name == "" else active_variables[token2.variable_name].value
				while_passed = pattern_operator.statement(value1, value2, while_passed_line_tokens[2])
				
				while_max += 1
				ifs_passed.append(while_tab + 1)
				for while_line in while_lines:
					await run_line(while_line, ifs, true)
			
			while_passed = false
			if while_max == 4096:
				add_to_console("While max reached. (4096)")
	# endregion While - End
	
	# region For Loop - Start
	elif in_for_loop and !is_recursive:
		if for_loop_tab < tokens[0].tabs:
			for_loop_lines.append(line)
		else:
			for i in for_loop_tokens[3].value:
				ifs_passed.append(for_loop_tab + 1)
				active_variables[for_loop_tokens[1].value] = Token.new("", for_loop_tokens[3].type, i)
				for for_line in for_loop_lines:
					await run_line(for_line, ifs, true)
			in_for_loop = false
	# endregion For Loop - End
	
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
			
			# [0: TOKEN_NAME, 1: TOKEN_LPAREN, 2: TOKEN_RPAREN, 3: TOKEN_END]
			if pattern == Constants.TOKEN_PATTERNS["CALL_FUNCTION"]:
				for function_line in functions[tokens[0].value]:
					ifs_passed.append(tokens[0].tabs + 1)
					await run_line(function_line, ifs, true)
			
			elif pattern != Constants.TOKEN_PATTERNS["ELSE_STATEMENT"]:
				await pattern_operator.create_output() 

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
				# WHILE_STATEMENT: [0: TOKEN_WHILE, 1: "VALUE", 2: "IF_OPERATOR", 3: "VALUE", 4: TOKEN_END]
				elif pattern == Constants.TOKEN_PATTERNS["WHILE_STATEMENT"]:
					while_passed_line = line # 'while x < 10'
					while_tab = tokens[0].tabs # 0 
					var value1 = tokens[1].value
					var value2 = tokens[3].value
					
					while_passed = pattern_operator.statement(value1, value2, tokens[2])
					while_passed_line_pattern = pattern_str
					while_passed_line_tokens = tokens
				# FOR_LOOP: [0: TOKEN_FOR, 1: TOKEN_NAME, 2: TOKEN_IN, 3: "VALUE", 4: TOKEN_END]
				elif pattern == Constants.TOKEN_PATTERNS["FOR_LOOP"]:
					active_variables[tokens[1].value] = tokens[3]
					for_loop_line = line # 0: for 1: i 2: in 3: 10
					for_loop_tab = tokens[0].tabs 
					for_loop_tokens = tokens
					for_loob_iterable_token = tokens[3]
					in_for_loop = true


			elif last_line_on_tab[0] in [Constants.TOKEN_PATTERNS["IF_STATEMENT"], Constants.TOKEN_PATTERNS["ELSE_IF_STATEMENT"]]:
				print("IFS ", ifs)
				if ifs == 0:
					ifs_passed.append(tokens[0].tabs + 1)
					await pattern_operator.create_output()
			else:
				Error.new("ERROR!", "UNKOWN ERROR")
				return
			
			last_lines[tokens[0].tabs] = [pattern, ifs_passed, tokens[0]]
	return ifs

func print_tokens(tokens):
	var string = "["
	for token in tokens:
		if token != tokens[0]:
			string += ", "
		string += token.type
		if token.value != null:
			string += ": " + str(token.value)

	print(string + "]")
