extends Node
class_name GridManager

signal resource_tiles_updated_event_handler(collected_tiles: int)
signal grid_state_updated_event_handler()

#var has_hover := false
#var occupied_cells: Array[Vector2i]
var vailable_buildable_tiles: Array[Vector2i]
var valid_buildable_attack_tiles: Array[Vector2i]
var collected_resource_tiles: Array[Vector2i]
var all_occuped_tiles: Array[Vector2i]
var all_tiles_in_building_radius: Array[Vector2i]
var danger_ocuppied_tiles: Array[Vector2i]
var attack_tiles: Array[Vector2i]

const IS_BUILDABLE: String = "is_buildable"
const IS_WOOD: String = "is_wood"
const IS_IGNORED = "is_ignored"

const TILE_SIZE := 64
@export var highlight_tile_map_layer: TileMapLayer
@export var base_terrain_tile_map_layer: TileMapLayer

var all_tile_map_layers: Array[TileMapLayer]
var tile_map_layer_to_elevation_layer: Dictionary[TileMapLayer, ElevationLayer]
var building_to_buildable_tiles: Dictionary[BuildingComponent, Array]
var danger_building_to_tiles: Dictionary[BuildingComponent, Array]
var attack_building_to_tiles: Dictionary[BuildingComponent, Array]

func _ready() -> void:
	GameEvents.building_placed_event_handler.connect(_on_building_placed_event_handler)
	GameEvents.building_destroyed_event_handler.connect(_on_building_destroy)
	GameEvents.building_disabled_event_handler.connect(_on_building_disabled)
	GameEvents.building_enabled_event_handler.connect(_on_building_enabled)
	all_tile_map_layers = get_all_tile_map_layers(base_terrain_tile_map_layer)
	map_tile_map_layer_to_elevation_layers()
	#print(all_tile_map_layers)

func get_tile_custom_data(tile_position: Vector2i, data_name: String) -> Array:
	for layer in all_tile_map_layers:
		var custom_data = layer.get_cell_tile_data(tile_position)
		if custom_data == null or bool(custom_data.get_custom_data(IS_IGNORED)): continue
		return [layer, bool(custom_data.get_custom_data(data_name))]
	return [null, false]

#func is_tile_position_resource(tile_position: Vector2i) -> bool:
	#for layer in all_tile_map_layers:
		#var custom_data = layer.get_cell_tile_data(tile_position)
		#if custom_data == null: continue
		#return bool(custom_data.get_custom_data(IS_WOOD))
	#return false

#func is_tile_position_buildable(tile_position: Vector2i) -> bool:
	#return vailable_buildable_tiles.has(tile_position)

func is_tile_position_in_any_building_radius(tile_position: Vector2i) -> bool:
	return all_tiles_in_building_radius.has(tile_position)


func is_tile_area_buildable(tile_area: Rect2, is_attack_tiles: bool = false) -> bool:
	var tiles: Array[Vector2i] = Rect2iExtensions.to_tiles(tile_area)
	if tiles.size() == 0: return false
	var first_tile_map_layer = get_tile_custom_data(tiles[0], IS_BUILDABLE)[0]
	var target_elevation_layer = tile_map_layer_to_elevation_layer.get(first_tile_map_layer, null)
	
	var tile_set_to_check := get_buildable_tile_set(is_attack_tiles)
	if is_attack_tiles:
		var new_tiles_to_check: Array[Vector2i]
		for tile in tile_set_to_check:
			if all_occuped_tiles.has(tile): continue
			new_tiles_to_check.append(tile)
		tile_set_to_check = new_tiles_to_check
	
	var pred := func(tile_pos: Vector2i) -> bool:
		var array_custom_data = get_tile_custom_data(tile_pos, IS_BUILDABLE)
		var elevation_layer = tile_map_layer_to_elevation_layer.get(array_custom_data[0])
		return array_custom_data[1] and tile_set_to_check.has(tile_pos) and elevation_layer == target_elevation_layer
	return tiles.all(pred)

func highlight_danger_occupied_tiles() -> void:
	var atlas_coords = Vector2i(2, 0)
	for tile_position in danger_ocuppied_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coords)

func highlight_buildable_tiles(is_attack_tiles: bool = false) -> void:
	for tile_position in get_buildable_tile_set(is_attack_tiles):
		highlight_tile_map_layer.set_cell(tile_position, 0, Vector2i.ZERO)

func highlight_expanded_buildable_tiles(tile_area: Rect2i, radius: int) -> void:
	var valid_tiles: Array[Vector2i] = get_valid_tiles_in_radius(tile_area, radius)
	var expanded_tiles: Array[Vector2i]
	#var occuped_tiles = get_occupied_tiles()
	for tile in valid_tiles:
		if vailable_buildable_tiles.has(tile): continue
		if all_occuped_tiles.has(tile): continue
		#if goblin_ocuppied_tiles.has(tile): continue
		expanded_tiles.append(tile)
	var atlas_coords = Vector2i(1, 0)
	for tile_position in expanded_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coords)

func highlight_attack_tiles(tile_area: Rect2i, radius: int) -> void:
	var building_area_tiles := Rect2iExtensions.to_tiles(tile_area)
	var valid_tiles: Array[Vector2i] = get_valid_tiles_in_radius(tile_area, radius)
	var new_valid_tiles: Array[Vector2i] 
	for tile in valid_tiles:
		if valid_buildable_attack_tiles.has(tile): continue
		if building_area_tiles.has(tile): continue
		new_valid_tiles.append(tile)
	
	var atlas_coords = Vector2i(1, 0)
	for tile_position in new_valid_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coords)

func highlight_resource_tiles(tile_area: Rect2i, radius: int) -> void:
	var resource_tiles = get_resource_tiles_in_radius(tile_area, radius)
	var atlas_coords = Vector2i(1, 0)
	for tile_position in resource_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coords)


func clear_highlight_tiles() -> void:
	highlight_tile_map_layer.clear()

func get_mouse_grid_cell_position_with_dimensions_offset(dimensions: Vector2) -> Vector2i:
	var mouse_grid_position: Vector2 = highlight_tile_map_layer.get_global_mouse_position() / TILE_SIZE
	mouse_grid_position -= dimensions / 2
	mouse_grid_position = mouse_grid_position.round()
	return Vector2i(int(mouse_grid_position.x), int(mouse_grid_position.y))

func get_mouse_grid_cell_position() -> Vector2i:
	var mouse_position: Vector2 = highlight_tile_map_layer.get_global_mouse_position()
	return convert_world_position_to_tile_position(mouse_position)

func convert_world_position_to_tile_position(world_position: Vector2) -> Vector2i:
	var tile_position = (world_position / TILE_SIZE).floor()
	return Vector2i(int(tile_position.x), int(tile_position.y))

func can_destroy_building(to_destroy_building_component: BuildingComponent) -> bool:
	if to_destroy_building_component.building_resource.buildable_radius > 0:
		return !will_building_destruction_create_orphan_buildings(to_destroy_building_component) and is_building_network_connected(to_destroy_building_component)
	elif to_destroy_building_component.building_resource.is_attack_building():
		return can_destroy_barracs(to_destroy_building_component)
	return true

func get_collected_resource_tiles() -> Array[Vector2i]:
	return collected_resource_tiles

func can_destroy_barracs(to_destroy: BuildingComponent) -> bool:
	# -- 1) danger buildings deshabilitados por el edificio a destruir --
	var danger_buildings: Array[BuildingComponent] = BuildingComponent.get_danger_building_component(self)
	var to_destroy_tiles: Array[Vector2i] = attack_building_to_tiles.get(to_destroy, [])  # Dict[BuildingComponent -> Array[Vector2i]]
	
	var disabled_danger_buildings: Array[BuildingComponent] = danger_buildings.filter(
		func(b: BuildingComponent) -> bool:
			#var tiles = Rect2iExtensions.to_tiles(b.get_tile_area())
			var tiles = b.get_occupied_cell_positions()
			return tiles.any(func(tp: Vector2i) -> bool:
				return to_destroy_tiles.has(tp)
			)
	)
	if disabled_danger_buildings.is_empty():
		return true
	
	# -- 2) ¿todos esos danger siguen deshabilitados por OTROS attack buildings? --
	# Unimos los tiles de todos los attack salvo el que se destruye (consulta O(1))
	var union_other := {}
	for attack_building in attack_building_to_tiles.keys():
		if attack_building == to_destroy:
			continue
		for t in attack_building_to_tiles[attack_building]:
			union_other[t] = true
	
	var all_danger_buildings_still_disabled := disabled_danger_buildings.all(
		func(db: BuildingComponent) -> bool:
			#var tiles = Rect2iExtensions.to_tiles(db.get_tile_area())
			var tiles = db.get_occupied_cell_positions()
			return tiles.any(func(tp: Vector2i) -> bool:
				return union_other.has(tp)
			)
	)
	if all_danger_buildings_still_disabled:
		return true
	
	# -- 3) Caso contrario: permitir destruir sólo si NINGÚN danger contiene celdas de edificios no-danger del jugador --
	var non_danger_buildings: Array[BuildingComponent] = BuildingComponent.get_non_danger_building_components(self).filter(func(n: BuildingComponent) -> bool: return n != to_destroy)
	
	var any_danger_contains_player_building := disabled_danger_buildings.any(
		func(danger_building: BuildingComponent) -> bool:
			var danger_tiles: Array[Vector2i] = danger_building_to_tiles.get(danger_building, [])
			return non_danger_buildings.any(
				func(n: BuildingComponent) -> bool:
					#var tiles_nd = Rect2iExtensions.to_tiles(n.get_tile_area())
					var tiles_nd = n.get_occupied_cell_positions()
					return tiles_nd.any(
						func(tp: Vector2i) -> bool:
							return danger_tiles.has(tp)
					)
			)
	)
	return not any_danger_contains_player_building


func will_building_destruction_create_orphan_buildings(to_destroy_building_component: BuildingComponent) -> bool:
	var dependent_buildings: Array[BuildingComponent] = BuildingComponent.get_non_danger_building_components(self)
	var final_dependent_buildings: Array[BuildingComponent] = []
	for d_b in dependent_buildings:
		var func_callable = func(tile_pos):
			if d_b == to_destroy_building_component: return false
			if d_b.building_resource.is_base: return false
			return building_to_buildable_tiles[to_destroy_building_component].has(tile_pos)
		#var any_tiles_radius = Rect2iExtensions.to_tiles(d_b.get_tile_area()).any(func_callable)
		var any_tiles_radius = d_b.get_occupied_cell_positions().any(func_callable)
		if (d_b != to_destroy_building_component) and any_tiles_radius:
			final_dependent_buildings.append(d_b)
	
	var f_c = func(dependent_building):
		#var tiles_for_building = Rect2iExtensions.to_tiles(dependent_building.get_tile_area())
		var tiles_for_building = dependent_building.get_occupied_cell_positions()
		var internal_func = func(tile_pos):
				var tile_is_in_set := false
				for bc in building_to_buildable_tiles.keys():
					if bc == to_destroy_building_component or bc == dependent_building:
						continue
					if building_to_buildable_tiles[bc].has(tile_pos):
						tile_is_in_set = true
						break
				return tile_is_in_set
		return tiles_for_building.all(internal_func)
		
	var all_buildings_still_valid = final_dependent_buildings.all(f_c)
	if !all_buildings_still_valid:
		return true
	return false

func is_building_network_connected(to_destroy_building_component: BuildingComponent) -> bool:
	var buildings = BuildingComponent.get_valid_building_components(self)
	var base_building: BuildingComponent 
	for build in buildings:
		if build.building_resource.is_base:
			base_building = build
			break
	var visit_buildings: Array[BuildingComponent]
	visit_all_connected_buildings(base_building, to_destroy_building_component, visit_buildings)
	var total_buildings = BuildingComponent.get_valid_building_components(self)
	var total_buildings_to_visit = 0
	for build in total_buildings:
		if build != to_destroy_building_component and build.building_resource.buildable_radius > 0:
			total_buildings_to_visit += 1 
	#print("visit_buildings.size() %d" % visit_buildings.size() )
	return total_buildings_to_visit == visit_buildings.size()

func visit_all_connected_buildings(
		root_building: BuildingComponent,
		exclude_building: BuildingComponent,
		visited_buildings: Array[BuildingComponent]
		) -> void:
	var dependents: Array[BuildingComponent] = []
	var root_tiles = building_to_buildable_tiles.get(root_building, [])
	
	for bc in BuildingComponent.get_non_danger_building_components(self):
		if bc.building_resource.buildable_radius == 0:
			continue
		if visited_buildings.has(bc):
			continue
		#var tiles := Rect2iExtensions.to_tiles(bc.get_tile_area())
		var tiles := bc.get_occupied_cell_positions()
		var any_tiles_in_radius := tiles.all(
			func(tp: Vector2i) -> bool:
				return root_tiles.has(tp))
		
		if bc != exclude_building and any_tiles_in_radius:
			dependents.append(bc)
		
		for d in dependents:
			if not visited_buildings.has(d):
				visited_buildings.append(d)
		
		for d in dependents:
			visit_all_connected_buildings(d, exclude_building, visited_buildings)

func get_buildable_tile_set(is_attack_tiles: bool = false) -> Array[Vector2i]:
	if is_attack_tiles:
		return valid_buildable_attack_tiles
	else:
		return vailable_buildable_tiles

func get_all_tile_map_layers(root_node: Node2D) -> Array[TileMapLayer]:
	var result: Array[TileMapLayer]
	var childrens = root_node.get_children()
	childrens.reverse()
	for child in childrens:
		if child is Node2D:
			result.append_array(get_all_tile_map_layers(child))
	if root_node is TileMapLayer:
		result.append(root_node)
	return result

func map_tile_map_layer_to_elevation_layers() -> void:
	for layer in all_tile_map_layers:
		var elevation_layer: ElevationLayer = null
		var start_node: Node = layer
		
		while (start_node != null and elevation_layer == null):
			start_node = start_node.get_parent()
			if start_node is ElevationLayer:
				elevation_layer = start_node as ElevationLayer
		
		if elevation_layer != null:
			tile_map_layer_to_elevation_layer[layer] = elevation_layer
	#print(tile_map_layer_to_elevation_layer)

func update_danger_occupied_tiles(building_component: BuildingComponent) -> void:
	
	for element in building_component.get_occupied_cell_positions():
		if all_occuped_tiles.has(element): continue
		all_occuped_tiles.append(element)
	
	if building_component.building_resource.is_danger_building():
		var tile_area = building_component.get_tile_area()
		var tiles_in_radius: Array[Vector2i] = get_valid_tiles_in_radius(tile_area, building_component.building_resource.danger_radius)
		
		danger_building_to_tiles[building_component] = tiles_in_radius
		
		if !building_component.is_disabled:
			for tile in tiles_in_radius:
				if danger_ocuppied_tiles.has(tile) or all_occuped_tiles.has(tile): continue
				danger_ocuppied_tiles.append(tile)

func update_valiable_buildable_tiles(building_component: BuildingComponent) -> void:
	#all_occuped_tiles.append(building_component.get_occupied_cell_positions())

	for element in building_component.get_occupied_cell_positions():
		if all_occuped_tiles.has(element): continue
		all_occuped_tiles.append(element)
	
	var tile_area = building_component.get_tile_area()

	if building_component.building_resource.buildable_radius > 0:
		var all_tiles = get_tiles_in_radius(tile_area, building_component.building_resource.buildable_radius, func(a): return true)
		for existing_building_vector in all_tiles:
			if all_tiles_in_building_radius.has(existing_building_vector): continue
			all_tiles_in_building_radius.append(existing_building_vector)
		
		var valid_tiles: Array[Vector2i] = get_valid_tiles_in_radius(tile_area, building_component.building_resource.buildable_radius)
		building_to_buildable_tiles[building_component] = valid_tiles
		vailable_buildable_tiles.append_array(valid_tiles)
	
	for tile_vector in all_occuped_tiles:
		vailable_buildable_tiles.erase(tile_vector)
	for tile_vector in vailable_buildable_tiles:
		if valid_buildable_attack_tiles.has(tile_vector): continue
		valid_buildable_attack_tiles.append(tile_vector)
	
	#print(valid_attack_tiles)
	for tile_vector in danger_ocuppied_tiles:
		vailable_buildable_tiles.erase(tile_vector)
	#print(vailable_buildable_tiles)
	grid_state_updated_event_handler.emit()

func update_collected_resource_tiles(building_component: BuildingComponent) -> void:
	var tile_area = building_component.get_tile_area()
	var resource_tiles = get_resource_tiles_in_radius(tile_area, building_component.building_resource.resource_radius)
	#var old_resource_tile_count = collected_resource_tiles.size()
	var changed := false
	for t in resource_tiles:
		if not collected_resource_tiles.has(t):
			collected_resource_tiles.append(t)
			changed = true
	#print(old_resource_tile_count, " ", collected_resource_tiles.size())
	if changed:
		resource_tiles_updated_event_handler.emit(collected_resource_tiles.size())
	grid_state_updated_event_handler.emit()

func update_attack_tiles(building_component: BuildingComponent) -> void:
	if !building_component.building_resource.is_attack_building(): return
	#attack_tiles

	var tile_area = building_component.get_tile_area()
	var new_attack_tiles = get_tiles_in_radius(tile_area, building_component.building_resource.attack_radius, func(a): return true)
	attack_building_to_tiles[building_component] = new_attack_tiles
	for tile in new_attack_tiles:
		if attack_tiles.has(tile): continue
		attack_tiles.append(tile)

func recalculate_grid() -> void:
	all_occuped_tiles.clear()
	vailable_buildable_tiles.clear()
	valid_buildable_attack_tiles.clear()
	all_tiles_in_building_radius.clear()
	collected_resource_tiles.clear()
	danger_ocuppied_tiles.clear()
	attack_tiles.clear()
	building_to_buildable_tiles.clear()
	danger_building_to_tiles.clear()
	attack_building_to_tiles.clear()
	#var building_components = get_tree().get_nodes_in_group(BuildingComponent.GROUP)
	var building_components = BuildingComponent.get_valid_building_components(self)
	for existing_building_component in building_components:
		update_building_component_grid_state(existing_building_component)
	
	check_danger_building_destruction()
	
	resource_tiles_updated_event_handler.emit(collected_resource_tiles.size())
	grid_state_updated_event_handler.emit()

func recalculate_danger_occupied_tiles():
	danger_ocuppied_tiles.clear()
	var danger_buildings = BuildingComponent.get_danger_building_component(self)
	for building in danger_buildings:
		update_danger_occupied_tiles(building)


func check_danger_building_destruction() -> void:
	var danger_buildings = BuildingComponent.get_danger_building_component(self)
	for building in danger_buildings:
		#var tile_area = building.get_tile_area()
		#var is_inside_attack_tile = Rect2iExtensions.to_tiles(tile_area).any(func(tile_pos): return attack_tiles.has(tile_pos))
		var is_inside_attack_tile = building.get_occupied_cell_positions().any(func(tile_pos): return attack_tiles.has(tile_pos))
		if is_inside_attack_tile:
			building.disable()
		else:
			building.enable()


func get_tiles_in_radius(tile_area: Rect2i, radius: int, filter_fn: Callable = func(_c: Vector2i) -> bool: return true) -> Array[Vector2i]:
	var result: Array[Vector2i]
	var tile_area_f: Rect2 = Rect2iExtensions.to_rect_2f(tile_area)
	var tile_area_center = tile_area_f.get_center()
	var radius_mod = maxf(tile_area_f.size.x, tile_area_f.size.y) / 2
	for x in range(tile_area.position.x - radius, tile_area.end.x + radius):
		for y in range(tile_area.position.y - radius, tile_area.end.y + radius):
			var tile_position = Vector2i(x, y)
			if(!is_tile_inside_circle(tile_area_center, tile_position, radius+radius_mod) or !filter_fn.call(tile_position)): continue
			#highlight_tile_map_layer.set_cell(Vector2i(int(x), int(y)), 0, Vector2i.ZERO)
			if (vailable_buildable_tiles.has(tile_position)): continue
			#if (collected_resource_tiles.has(tile_position)): continue
			result.append(Vector2i(x, y))
	return result

func is_tile_inside_circle(center_position: Vector2, tile_position: Vector2, radius: float) -> bool:
	var distance_x = center_position.x - (tile_position.x + 0.5)
	var distance_y = center_position.y - (tile_position.y + 0.5)
	var distance_squared = (distance_x * distance_x) + (distance_y * distance_y)
	return (distance_squared <= (radius * radius))

func get_valid_tiles_in_radius(tile_area: Rect2i, radius: int) -> Array[Vector2i]:
	return get_tiles_in_radius(
		tile_area,
		radius,
		func(tile_pos: Vector2i) -> bool: return get_tile_custom_data(tile_pos, IS_BUILDABLE)[1]
	)

func get_resource_tiles_in_radius(tile_area: Rect2i, radius: int) -> Array[Vector2i]:
	return get_tiles_in_radius(
		tile_area,
		radius,
		func(tile_pos: Vector2i) -> bool: return get_tile_custom_data(tile_pos, IS_WOOD)[1]
	)

func update_building_component_grid_state(building_component: BuildingComponent) -> void:
	#print("recalculate grid")
	update_danger_occupied_tiles(building_component)
	update_valiable_buildable_tiles(building_component)
	update_collected_resource_tiles(building_component)
	update_attack_tiles(building_component)

func _on_building_placed_event_handler(building_component: BuildingComponent) -> void:
	#print(building_component)
	update_building_component_grid_state(building_component)
	check_danger_building_destruction()

func _on_building_destroy(building_component: BuildingComponent) -> void:
	recalculate_grid()

func _on_building_enabled(building_component: BuildingComponent) -> void:
	update_building_component_grid_state(building_component)
	recalculate_grid()

func _on_building_disabled(building_component: BuildingComponent) -> void:
	recalculate_grid()
