extends Resource
class_name LevelDefinitionResource

@export var id: String
@export var starting_resource_count: int = 4
@export_file("*.tscn") var level_scene_path: String
