extends Node
class_name ParseResult

var error = null
var node = null

func register(result):
	if is_instance_of(result, ParseResult):
		if result.error: error = result.error
		return result.node
	
	return result

func success(node_):
	node = node_
	return self

func failure(error_):
	error = error_
	print(error.get_str())

func get_str():
	if node != null:
		return node.get_str()
	return "node is null"
