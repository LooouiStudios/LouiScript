extends Node
class_name Parser

var tokens
var token_idx = -1
var current_token = null

func _init(tokens_):
	token_idx = -1
	current_token = null
	tokens = tokens_
	advance()

func advance():
	token_idx += 1
	if token_idx < tokens.size():
		current_token = tokens[token_idx]
	return current_token

func parse():
	var result = expression()
	if not result.error and current_token.type != Constants.TOKEN_END:
		return result.failure(Error.new("Invalid Syntax", "Expected '+', '-', '*' or '/'"))
	return result

# Factor : INT|FLOAT
func factor():
	var result = ParseResult.new()
	var token = current_token
	
	if token.type in [Constants.TOKEN_PLUS, Constants.TOKEN_MINUS]:
		result.register(advance())
		var factor = result.register(factor()) 
		if result.error: return result
		return result.success(UnaryOperationNode.new(token, factor))
	
	elif token.type in [Constants.TOKEN_INT, Constants.TOKEN_FLOAT]:
		result.register(advance())
		return result.success(NumberNode.new(token))
	
	elif token.type == Constants.TOKEN_LPAREN:
		result.register(advance())
		var expression = result.register(expression())
		if result.error: return result
		if current_token.type == Constants.TOKEN_RPAREN:
			result.register(advance())
			return result.success(expression())
		else:
			return result.failure(Error.new("Invalid Syntax", "Expected ')'"))
	
	return result.failure(Error.new("Invalid Syntax", "Expected a int or float"))

# Term : Factor ((MUL|DIV) Factor)
func term():
	return binary_operation("factor", Constants.TOKEN_MULTIPLY, Constants.TOKEN_DIVIDE)

# Expression : Term((PLUS|MINUS) Term)
func expression():
	return binary_operation("term", Constants.TOKEN_PLUS, Constants.TOKEN_MINUS)

func binary_operation(function, op1, op2):
	var result = ParseResult.new()
	var left = result.register(call(function))
	if result.error: return result
	
	while current_token.type == op1 or current_token.type == op2:
		var operator_token = current_token
		result.register(advance())
		var right = result.register(call(function))
		if result.error: return result
		print("Creating binop. These are L/R ", left.get_str(), " ", right.get_str())
		left = BinaryOperationsNode.new(left, operator_token, right)
	
	return result.success(left)
