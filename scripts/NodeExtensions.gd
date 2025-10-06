extends Node
class_name NodeExtensions


#func get_first_node_of_type() -> void:
	#pass

static func get_first_node_of_type(node: Node, type_name: StringName, recursive := false, owned := false) -> Node:
	var found := node.find_children("", type_name, recursive, owned)
	return found[0] if not found.is_empty() else null
