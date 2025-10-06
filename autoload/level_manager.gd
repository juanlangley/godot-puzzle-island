extends Node

@export var level_definitions: Array[LevelDefinitionResource]
var current_level_index: int

func _ready() -> void:
	pass

func get_level_definitions() -> Array[LevelDefinitionResource]:
	return level_definitions.duplicate()

func change_to_level(level_index: int) -> void:
	if level_index >= level_definitions.size() or level_index < 0: return
	current_level_index = level_index
	var level_definition = level_definitions[current_level_index]
	get_tree().change_scene_to_file(level_definition.level_scene_path)

func change_to_next_level():
	change_to_level(current_level_index + 1)
