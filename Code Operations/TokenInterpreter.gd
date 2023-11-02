extends Node
class_name TokenInterpreter

var tokens = []

func _init(input_tokens):
	tokens = input_tokens

func run_interpreter():
	var simplified_tokens = simplify_tokens(tokens)
	return simplified_tokens

func simplify_tokens(tokens):
	var result = []
	var value_stack = []
	var operator_stack = []
	var rest_of_function = []

	for token in tokens:
		if token.type in ["INT", "FLOAT"]:
			value_stack.append(token)
		elif token.type == "PLUS" or token.type == "MULTIPLY" or token.type == "MINUS":
			while operator_stack.size() > 0 and precedence(operator_stack[-1]) >= precedence(token):
				var operator = operator_stack.pop_back()
				var second = value_stack.pop_back()
				var first = value_stack.pop_back()
				if first and second:
					var result_value = calculate(operator, first, second)
					if result_value:
						value_stack.append(result_value)
			operator_stack.append(token)
		elif token.type == "LPAREN":
			operator_stack.append(token)
			rest_of_function.append(token)
		elif token.type == "RPAREN":
			rest_of_function.append(token)
			while operator_stack.size() > 0 and operator_stack[-1].type != "LPAREN":
				var operator = operator_stack.pop_back()
				var second = value_stack.pop_back()
				var first = value_stack.pop_back()
				if first and second:
					var result_value = calculate(operator, first, second)
					if result_value:
						value_stack.append(result_value)
				operator_stack.pop_back()  # Pop the LPAREN
		else:
			rest_of_function.append(token)

	while operator_stack.size() > 0:
		var operator = operator_stack.pop_back()
		var second = value_stack.pop_back()
		var first = value_stack.pop_back()
		if first and second:
			var result_value = calculate(operator, first, second)
			if result_value:
				value_stack.append(result_value)

	if value_stack.size() > 0:
		if value_stack.size() > 1:
			var total_value = value_stack[0]
			for i in range(1, value_stack.size()):
				total_value = calculate(operator_stack[0], total_value, value_stack[i])
			value_stack = [total_value]
		
		var value_added : bool
		var r_paren_count = 0
		for token in rest_of_function:
			result.append(token)
			if rest_of_function[rest_of_function.find(token) - 1].type == "CALL_FUNCTION":
				if token.type == "LPAREN" and !value_added:
					result.append(value_stack[0])
					value_added = true
				elif token.type == "LPAREN":
					result.erase(result.size() - 1)
				elif token.type == "RPAREN":
					r_paren_count += 1
					if r_paren_count == 2:
						result.erase(result.size() - 1)
	return result

func calculate(operator, first, second):
	if operator.type == "PLUS":
		return Token.new("FLOAT", str(float(first.value) + float(second.value)))
	elif operator.type == "MULTIPLY":
		return Token.new("FLOAT", str(float(first.value) * float(second.value)))

func precedence(op):
	if op.type == "MULTIPLY":
		return 2
	if op.type == "PLUS":
		return 1
	return 0

func print_tokens(tokens):
	var string = "["
	for token in tokens:
		if token != tokens[0]:
			string += ", "
		string += token.type
		if token.value != null:
			string += ": " + str(token.value)

	print(string + "]")
