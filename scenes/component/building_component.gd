extends Node2D
class_name BuildingComponent

const GROUP: StringName = "BuildingComponent"

@export var building_animation_component: BuildingAnimatorComponent
@export_file("*.tres") var building_resource_path: String
var building_resource: BuildingResource
#@export_file("*.tres") var building_resource_path: String = ""
var occupied_tiles: Array[Vector2i]
var is_destroying: bool = false
var is_disabled: bool = false

static func get_valid_building_components(node: Node) -> Array[BuildingComponent]:
	var nodes = node.get_tree().get_nodes_in_group(GROUP)
	var result: Array[BuildingComponent]
	for n in nodes:
		if n is BuildingComponent and !n.is_destroying:
			result.append(n as BuildingComponent)
	return result

static func get_danger_building_component(node: Node) -> Array[BuildingComponent]:
	var nodes = node.get_tree().get_nodes_in_group(GROUP)
	var result: Array[BuildingComponent]
	for n in nodes:
		if n is BuildingComponent and n.building_resource.is_danger_building():
			result.append(n as BuildingComponent)
	return result

func _ready() -> void:
	if building_resource_path != "":
		building_resource = load(building_resource_path) as BuildingResource
	else:
		push_error("No existe: %s" % building_resource_path)
	
	if building_animation_component != null:
		building_animation_component.destroy_animation_finished.connect(_on_destroy_animation_finished)
	
	add_to_group(GROUP)
	#await get_tree().process_frame
	#GameEvents.call_deferred("emit_signal", "building_placed_event_handler", self)
	initialize.call_deferred()
	#GameEvents.building_placed_event_handler.emit.call_deferred(self)

func get_grid_cell_position() -> Vector2i:
	var grid_position =(global_position / 64).floor()
	return Vector2i(int(grid_position.x), int(grid_position.y))

func get_occupied_cell_positions() -> Array[Vector2i]:
	return occupied_tiles

func get_tile_area() -> Rect2i:
	var root_cell = get_grid_cell_position()
	var tile_area = Rect2i(root_cell, building_resource.dimensions)
	return tile_area

func is_tile_in_building_area(tile_position: Vector2i) -> bool:
	return occupied_tiles.has(tile_position)

func disable() -> void:
	if is_disabled: return
	is_disabled = true
	GameEvents.building_disabled_event_handler.emit.call_deferred(self)

func enable() -> void:
	if !is_disabled: return
	is_disabled = false
	GameEvents.building_enabled_event_handler.emit.call_deferred(self)

func destroy() -> void:
	is_destroying = true
	GameEvents.building_destroyed_event_handler.emit.call_deferred(self)
	building_animation_component.play_destroy_animation()
	if building_animation_component == null:
		owner.queue_free()

func calculate_occupied_cell_positions() -> void:
	var grid_position = get_grid_cell_position()
	for x in range(grid_position.x, grid_position.x + building_resource.dimensions.x ):
		for y in range(grid_position.y, grid_position.y + building_resource.dimensions.y):
			occupied_tiles.append(Vector2i(x,y))

func initialize() -> void:
	calculate_occupied_cell_positions()
	GameEvents.building_placed_event_handler.emit(self)

func _on_destroy_animation_finished() -> void:
	owner.queue_free()
