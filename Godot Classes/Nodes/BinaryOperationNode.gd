extends Node
class_name BinaryOperationsNode
# Node for Add, substract, multiply and divide operations AKA binary operations
var left_node
var operator_token
var right_node

func _init(left_node_, operator_token_, right_node_):
	left_node = left_node_ # number
	operator_token = operator_token_ # + - * /
	right_node = right_node_ # number
	
	if left_node is ParseResult:
		left_node = left_node.node
	
	if right_node is ParseResult:
		right_node = right_node.node

func get_str():
	return "(" + left_node.get_str() + ", " + str(operator_token.type) + ", " + right_node.get_str() + ")"


# (3.5, PLUS, (2, MULTIPLY, 2))
