extends Node
class_name TokenCreator

# Lexer is based of CodePulse's python tutorial series for a BASIC like langauge

var tokens = []
var pos = -1
var current_char = null
var line : String
var main = null

func error(text : String):
	main.add_to_console(text)

func _init(text : String, _main_):
	line = text
	main = _main_
	pos = -1
	current_char = null
	advance()
	
	tokens = create_tokens()

func advance(change = 1):
	pos += change
	current_char = line[pos] if pos < len(line) else null

func create_tokens():
	var new_tokens = []
	var advance_auto = false
	
	while current_char != null:
		if current_char == " ":
			advance()
		
		if advance_auto:
			if current_char == ">":
				advance()
				if current_char == ">":
					advance_auto = false
			advance()
		
		elif current_char == "<": # Comments
			advance()
			if current_char == "<":
				advance_auto = true
			elif current_char == "=":
				new_tokens.append(Token.new(line, Constants.TOKEN_BIGGER_OR_EQUAL_TO))
			else:
				new_tokens.append(Token.new(line, Constants.TOKEN_BIGGER_THAN))
		
		elif current_char == null:
			break
		
		elif current_char == ">":
			advance()
			if current_char == "=":
				new_tokens.append(Token.new(line, Constants.TOKEN_LESS_OR_EQUAL_TO))
			else:
				new_tokens.append(Token.new(line, Constants.TOKEN_LESS_THAN))
		elif current_char == '"': # Strings
			new_tokens.append(make_string())
		elif current_char in Constants.DIGITS: # Numbers
			new_tokens.append(make_number())
		elif current_char == "@": # Defining variables
			new_tokens.append(make_variable_token())
		elif current_char == "+":
			new_tokens.append(Token.new(line, Constants.TOKEN_PLUS))
			advance()
		elif current_char == "-":
			new_tokens.append(Token.new(line, Constants.TOKEN_MINUS))
			advance()
		elif current_char == "*":
			new_tokens.append(Token.new(line, Constants.TOKEN_MULTIPLY))
			advance()
		elif current_char == "/":
			new_tokens.append(Token.new(line, Constants.TOKEN_DIVIDE))
			advance()
		elif current_char == "(":
			new_tokens.append(Token.new(line, Constants.TOKEN_LPAREN))
			advance()
		elif current_char == ")":
			new_tokens.append(Token.new(line, Constants.TOKEN_RPAREN))
			advance()
		elif current_char == "=":
			new_tokens.append(make_equals())
			advance()
		elif current_char == ",":
			new_tokens.append(Token.new(line, Constants.TOKEN_COMMA))
			advance()
		elif current_char == "!":
			advance()
			if current_char == "=":
				new_tokens.append(Token.new(line, Constants.TOKEN_NOT_EQUAL_TO))
			else:
				Error.new("Invalid Syntax", "A '!' must be followed up with a '='")
		elif current_char in Constants.ALPHABET:
			new_tokens.append(make_keyword_token())
		else:
			advance()
	
	new_tokens.append(Token.new(line, Constants.TOKEN_END))
	return new_tokens

func make_number():
	var number_str = ""
	var dot_count = 0
	
	while current_char != null and current_char in Constants.DIGITS + "._":
		if current_char == ".":
			if dot_count == 1: break
			dot_count += 1
			number_str += "."
		else:
			number_str += current_char
		advance()
	
	if dot_count == 0:
		return Token.new(line, Constants.TOKEN_INT, int(number_str))
	else:
		return Token.new(line, Constants.TOKEN_FLOAT, float(number_str))

func make_variable_token():
	var variable_name = ""
	advance()
	if current_char in Constants.DIGITS:
		Error.new("Invalid Syntax", "The first characther of a variable can not be a digit.")
		return null
	while current_char != "," and current_char != null:
		variable_name += current_char
		advance()
	
	if current_char == null:
		Error.new("Invalid Syntax", "Expected ',' at end of variable definition.")
	
	elif current_char == ",":
		advance()
		return Token.new(line, Constants.TOKEN_VARIABLE, variable_name)

func make_keyword_token():
	var value_type = ""
	while current_char != null and current_char in Constants.ALPHABET:
		value_type += current_char
		advance()
	
	print(main.active_variables)
	
	if value_type in Constants.VALUE_TYPES:
		return Token.new(line, Constants.TOKEN_VALUE_TYPE, value_type)
	
	elif value_type in Constants.KEYWORDS:
		if value_type in ["true", "false"]:
			var value = true if value_type == "true" else false
			return Token.new(line, Constants.TOKEN_BOOL, value)
	
	elif value_type in Constants.IN_BUILT_FUNCTIONS or value_type in Constants.CUSTOM_FUNCTIONS:
		return Token.new(line, Constants.TOKEN_CALL_FUNCTION, value_type)
	
	elif value_type in main.active_variables.keys():
		var token = main.active_variables[value_type]
		if token != null:
			return Token.new(line, token.type, token.value, value_type)
	
	elif value_type == "if":
		return Token.new(line, Constants.TOKEN_IF)
	
	elif value_type == "else":
		return Token.new(line, Constants.TOKEN_ELSE)
	
	elif value_type == "while":
		return Token.new(line, Constants.TOKEN_WHILE)
	
	elif value_type == "for":
		return Token.new(line, Constants.TOKEN_FOR)
	
	elif value_type == "in":
		return Token.new(line, Constants.TOKEN_IN)
	
	elif value_type == "def":
		return Token.new(line, Constants.TOKEN_DEFINE_FUNCTION)
		
	else:
		return Token.new(line, Constants.TOKEN_NAME, value_type)
		#Error.new("Invalid Syntax", "Sorry, we are not able to identify the problem, but there is a referance without any value.")

func make_equals():
	advance()
	if current_char == "=":
		return Token.new(line, Constants.TOKEN_EQUAL_TO)
	advance(-1)
	return Token.new(line, Constants.TOKEN_EQUALS)

func make_string():
	advance()
	var string = ""
	while current_char != null and current_char != '"':
		string += current_char
		advance()
	
	if current_char == '"':
		advance()
		return Token.new(line, Constants.TOKEN_STRING, string)
	else:
		Error.new("Invalid syntax", 'Expected a closing quatation mark (").')

func print_tokens():
	var string = "["
	for token in tokens:
		if token != tokens[0]:
			string += ", "
		string += token.type
		if token.value != null:
			string += ": " + str(token.value)
	
	print(string + "]")
