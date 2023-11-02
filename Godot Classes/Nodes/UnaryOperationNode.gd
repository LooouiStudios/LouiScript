extends Node
class_name UnaryOperationNode

var operation_token
var node

func _init(op_tok, _node):
	operation_token = op_tok
	node = _node

func get_str():
	return str(operation_token.type) + ", " + str(node.token.value)
