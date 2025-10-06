extends Node
class_name BuildingManager

const ACTION_LEFT_CLICK: StringName = "left_click"
const ACTION_CANCEL: StringName = "cancel"
const ACTION_RIGHT_CLICK: StringName = "right_click"

@export var grid_manager: GridManager
@export var game_ui: GameUI
@export var y_sort_root: Node2D
@export var building_ghost_scene: PackedScene

signal available_resource_count_changed(available_resource_count: int)

enum STATE {
	NORMAL,
	PLACING_BUILDING
}

var starting_resource_count: int
var current_resource_count: int
var currently_used_resource_count: int
var to_place_building_scene: BuildingResource
var hover_grid_area: Rect2i = Rect2i(Vector2i.ONE, Vector2i.ONE)
var has_hover := false
var building_ghost: BuildingGhost
var building_ghost_dimensions: Vector2
var current_state: STATE

var available_resource_count: int:
	get:
		return starting_resource_count + current_resource_count - currently_used_resource_count

func _ready() -> void:
	grid_manager.resource_tiles_updated_event_handler.connect(_on_resource_tiles_update)
	game_ui.building_resource_selected_event.connect(_on_building_resource_selected)
	
	#available_resource_count_changed.emit.call_deferred(available_resource_count)

func _process(delta: float) -> void:
	var mouse_grid_position: Vector2i = Vector2i.ZERO
	match current_state:
		STATE.NORMAL:
			mouse_grid_position = grid_manager.get_mouse_grid_cell_position()
		STATE.PLACING_BUILDING:
			mouse_grid_position = grid_manager.get_mouse_grid_cell_position_with_dimensions_offset(building_ghost_dimensions)
			building_ghost.global_position = mouse_grid_position * grid_manager.TILE_SIZE
	
	#if !is_instance_valid(building_ghost): return
	var root_cell = hover_grid_area.position
	if root_cell != mouse_grid_position:
		hover_grid_area.position = mouse_grid_position
		update_hovered_grid_area()


func set_starting_resource_count(count: int) -> void:
	starting_resource_count = count
	available_resource_count_changed.emit.call_deferred(available_resource_count)

func update_grid_display() -> void:
	#if !hover_cell: return
	grid_manager.clear_highlight_tiles()
	
	if to_place_building_scene.is_attack_building():
		grid_manager.highlight_goblin_occupied_tiles()
		grid_manager.highlight_buildable_tiles(true)
	else:
		grid_manager.highlight_buildable_tiles()
		grid_manager.highlight_goblin_occupied_tiles()
	
	if (is_building_placeable_at_area(hover_grid_area)):
		if to_place_building_scene.is_attack_building():
			grid_manager.highlight_attack_tiles(hover_grid_area, to_place_building_scene.attack_radius)
		else:
			grid_manager.highlight_expanded_buildable_tiles(hover_grid_area, to_place_building_scene.buildable_radius)
		grid_manager.highlight_resource_tiles(hover_grid_area, to_place_building_scene.resource_radius)
		building_ghost.set_valid()
	else:
		building_ghost.set_invalid()
	building_ghost.do_hover_animation()

func _unhandled_input(event: InputEvent) -> void:
	#print(event)
	match current_state:
		STATE.NORMAL:
			if event.is_action_pressed(ACTION_RIGHT_CLICK):
				destroy_building_at_hovered_cell_position()
		STATE.PLACING_BUILDING:
			if event.is_action_pressed(ACTION_CANCEL):
				change_state(STATE.NORMAL)
			elif (#has_hover and 
				#to_place_building_scene != null and
				event.is_action_pressed(ACTION_LEFT_CLICK) and 
				is_building_placeable_at_area(hover_grid_area)
			):
				place_building_at_mouse_position()
		_:
			pass


func place_building_at_mouse_position():
	#if !has_hover: return
	var build: Node2D = to_place_building_scene.building_scene.instantiate()
	y_sort_root.add_child(build)
	build.global_position = hover_grid_area.position * grid_manager.TILE_SIZE
	#grid_manager.mark_tile_as_occupied(hover_cell)
	var first_node = NodeExtensions.get_first_node_of_type(build, "BuildingAnimatorComponent", true, false)
	if first_node != null:
		(first_node as BuildingAnimatorComponent).play_in_animation()
	currently_used_resource_count += to_place_building_scene.resource_cost
	change_state(STATE.NORMAL)
	available_resource_count_changed.emit(available_resource_count)
	#print("starting_resource_count ", starting_resource_count)
	#print("current_resource_count ", current_resource_count)
	#print("currently_used_resource_count ", currently_used_resource_count)
	#print("available_resource_count ", available_resource_count)

func destroy_building_at_hovered_cell_position() -> void:
	
	var root_cell = hover_grid_area.position
	var buildings_in_tile: BuildingComponent
	for bc in BuildingComponent.get_valid_building_components(self):
		if bc.building_resource.is_deletable and bc.is_tile_in_building_area(root_cell):
			buildings_in_tile = bc
			break
	if buildings_in_tile == null: return
	if !grid_manager.can_destroy_building(buildings_in_tile): return
	currently_used_resource_count -= buildings_in_tile.building_resource.resource_cost
	buildings_in_tile.destroy()
	#print(available_resource_count)
	available_resource_count_changed.emit(available_resource_count)
	

func clear_building_ghost() -> void:
	#has_hover = false
	grid_manager.clear_highlight_tiles()
	if is_instance_valid(building_ghost):
		building_ghost.queue_free()
	building_ghost = null


func is_building_placeable_at_area(tile_area: Rect2i) -> bool:
	var is_attack_tiles = to_place_building_scene.is_attack_building()
	var all_tiles_buildable = grid_manager.is_tile_area_buildable(tile_area, is_attack_tiles)
	return (all_tiles_buildable and available_resource_count >= to_place_building_scene.resource_cost)

#func get_tile_positions_in_tile_area(tile_area: Rect2i) -> Array[Vector2i]:
	#var result: Array[Vector2i]
	#for x in range(tile_area.position.x, tile_area.end.x):
		#for y in range(tile_area.position.y, tile_area.end.y):
			#result.append(Vector2i(x, y))
	#return result

func update_hovered_grid_area() -> void:
	match current_state:
		STATE.NORMAL:
			pass
		STATE.PLACING_BUILDING:
			update_grid_display()

func change_state(to_state: STATE) -> void:
	match current_state:
		STATE.NORMAL:
			pass
		STATE.PLACING_BUILDING:
			clear_building_ghost()
			to_place_building_scene = null
			
	current_state = to_state
	match current_state:
		STATE.NORMAL:
			pass
		STATE.PLACING_BUILDING:
			building_ghost = building_ghost_scene.instantiate()
			y_sort_root.add_child(building_ghost)

func _on_resource_tiles_update(resource_count: int) -> void:
	current_resource_count = resource_count
	available_resource_count_changed.emit(available_resource_count)

func _on_building_resource_selected(building_resource: BuildingResource) -> void:
	#if is_instance_valid(building_ghost):
		#building_ghost.queue_free()
	change_state(STATE.PLACING_BUILDING)
	hover_grid_area.size = building_resource.dimensions
	#building_ghost = building_ghost_scene.instantiate()
	#y_sort_root.add_child(building_ghost)
	var building_sprite = building_resource.sprite_scene.instantiate()
	building_ghost.add_sprite_node(building_sprite)
	building_ghost.set_dimensions(building_resource.dimensions)
	building_ghost_dimensions = building_resource.dimensions
	to_place_building_scene = building_resource
	#cursor.visible = true
	grid_manager.highlight_buildable_tiles()
	update_grid_display()
