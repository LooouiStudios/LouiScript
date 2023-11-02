extends Node
class_name PatternOperator

var pattern
var tokens
var main

# Called when the node enters the scene tree for the first time.
func _init(_pattern_ : String, _tokens_ : Array, _main_ : Object):
	pattern = _pattern_
	tokens = _tokens_
	main = _main_

func create_output():
	# [0: TOKEN_VARIABLE, 1: TOKEN_VALUE_TYPE, 2: TOKEN_EQUALS, 3: "VALUE", 4: TOKEN_END]
	if pattern == "DEFINE_VARIABLE":
		return define_variable(tokens[3])
	
	# [0: TOKEN_VARIABLE, 1: TOKEN_VALUE_TYPE, 2: TOKEN_EQUALS, 3: TOKEN_CALL_FUNCTION, 4: TOKEN_LPAREN, 5: "VALUE", 6: TOKEN_RPAREN, 7: TOKEN_END]
	elif pattern == "DEFINE_VARIABLE_WITH_FUNCTION_CALL+_INPUT":
		if tokens[3].value == "input":
			var input = await input_function(tokens[5])
			define_variable(Token.new("", Constants.TOKEN_STRING, input))
			return "success"
		
		elif tokens[3].value == "make_int":
			define_variable(Token.new("", Constants.TOKEN_INT, int(tokens[5].value)))
			return "success"
		
		elif tokens[3].value == "make_float":
			define_variable(Token.new("", Constants.TOKEN_FLOAT, float(tokens[5].value)))
			return "success"
		
		elif tokens[3].value == "make_string":
			define_variable(Token.new("", Constants.TOKEN_INT, str(tokens[5].value)))
			return "success"
		
		elif tokens[3].value == "len":
			define_variable(Token.new("", Constants.TOKEN_INT, len(tokens[5].value)))
			return "success"
	
	# [0: TOKEN_VARIABLE, 1: TOKEN_VALUE_TYPE, 2: TOKEN_EQUALS, 3: TOKEN_CALL_FUNCTION, 4: TOKEN_LPAREN, 5: "VALUE", 6: TOKEN_COMMA, 7: "VALUE", 8: TOKEN_RPAREN, 9: TOKEN_END]
	elif pattern == "DEFINE_VARIABLE_WITH_FUNCTION_CALL+_INPUT_2":
		if tokens[3].value == "add":
			define_variable(Token.new("",tokens[1].value, tokens[5].value + tokens[7].value))
			return "success"
		elif tokens[3].value == "subtract":
			define_variable(Token.new("",tokens[1].value, tokens[5].value - tokens[7].value))
			return "success"
		elif tokens[3].value == "multiply":
			define_variable(Token.new("",tokens[1].value, tokens[5].value * tokens[7].value))
			return "success"
		elif tokens[3].value == "divide":
			define_variable(Token.new("",tokens[1].value, tokens[5].value / tokens[7].value))
			return "success"
		elif tokens[3].value == "random_int":
			if tokens[5].type == "INT" and tokens[7].type == "INT":
				define_variable(Token.new("",tokens[1].value, randi_range(tokens[5].value, tokens[7].value)))
			else:
				Error.new("Invalid Types", "In a 'random_int' function both values must be ints")
	
	
	# [0: TOKEN_CALL_FUNCTION, 1: TOKEN_LPAREN, 2: "VALUE", 3: TOKEN_RPAREN, 4: TOKEN_END]
	elif pattern == "FUNCTION_CALL_+_INPUT":
		if tokens[0].value == "print":
			var print_str = str(tokens[2].value)
			main.add_to_console(print_str, true)
			return "success"
		
		elif tokens[0].value == "printc":
			if main.last_used_label != null:
				main.last_used_label.text += str(tokens[2].value)
			else:
				Error.new("Invalid Call", "Cant use 'printc' if you havent already used 'print'.")
				return "failure"
			return "success"
		
		elif tokens[0].value == "input":
			await input_function(tokens[2])
			print("Disclaimer input value is being discarded!")
			return "success"
		
		elif tokens[0].value == "make_int" or tokens[0].value == "make_float" or tokens[0].value == "make_string":
			Error.new("Useless Operation", tokens[0].value.split("_")[1] + " is being discarded and therefore not computed.")
			return "success" # <- return success because the program will still work with this line in it
		
		elif tokens[0].value == "get_type":
			main.console.print_console(tokens[2].type.to_lower())
	
	# [0: TOKEN_IF, 1: "VALUE", 2: "IF_OPERATOR", 3: "VALUE", 4: TOKEN_END]
	elif pattern == "IF_STATEMENT":
		var result : bool
		
		var value1 = tokens[1].value
		var value2 = tokens[3].value
		
		if tokens[2].type == "EQUAL_TO":
			result = value1 == value2
		
		elif tokens[2].type == "NOT_EQUAL_TO":
			result = value1 != value2
		
		elif tokens[2].type == "BIGGER_THAN":
			result = value1 < value2
		
		elif tokens[2].type == "LESS_THAN":
			result = value1 > value2
		
		print(value1, " ", value2)
		print("Result: ", result)
		if result:
			main.ifs_passed.append(tokens[0].tabs + 1)
		
		return "success"

func define_variable(VALUE):
	var VARIABLE_NAME = tokens[0]; var VARIABLE_TYPE = tokens[1];
	if VALUE.type.to_upper() == VARIABLE_TYPE.value.to_upper():
		main.active_variables[VARIABLE_NAME.value] = VALUE
		print("VARIABLE " + VARIABLE_NAME.value + " DEFINED!")
		Constants.DEFINED_VARIABLE.append(VARIABLE_NAME.value)
		print("defined variable")
		return "success"
	else:
		Error.new("Invalid Variable Definition", "Variable: " + str(VARIABLE_NAME.value) + 
		" value type does not correspond with its value. Defined type: " + 
		str(VARIABLE_TYPE.value).to_upper() + " Actual type: " + str(VALUE.type))
		return "failure"

func input_function(value) -> String:
	var input_popup = Constants.main.get_node("InputPopUp")
	input_popup.show()
	var textedit = input_popup.get_node("TextEdit"); textedit.text = ""
	var label = input_popup.get_node("Label")
	
	if value.type != Constants.TOKEN_STRING:
		Error.new("Invalid Syntax", "Input cant be called with anything, but a string. You've called it with a " + str(tokens[5].type))
		return "failure"
	label.text = value.value
	
	await input_popup.finished
	
	input_popup.hide()
	return textedit.text
