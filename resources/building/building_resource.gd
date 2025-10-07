extends Resource
class_name BuildingResource

@export var display_name: String
@export var description: String
@export var dimensions: Vector2i = Vector2i.ONE

@export var is_base: bool
@export var resource_cost: int
@export var buildable_radius: int
@export var resource_radius: int
@export var danger_radius: int
@export var attack_radius: int
@export var building_scene: PackedScene
@export var sprite_scene: PackedScene

@export var is_deletable: bool = true

func is_attack_building() -> bool:
	return attack_radius > 0

func is_danger_building() -> bool:
	return danger_radius > 0
