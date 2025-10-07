extends Node

@export var grid_manager: GridManager
@export var resource_indicator_scene: PackedScene
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var indicated_tiles: Array[Vector2i]
var tile_to_resource_indicator: Dictionary[Vector2i, ResourceIndicator]

func _ready() -> void:
	grid_manager.resource_tiles_updated_event_handler.connect(_on_resource_tiles_updated)


func update_indicator(new_indicated_tiles: Array[Vector2i], to_remove_tiles: Array[Vector2i]) -> void:
	if new_indicated_tiles.size() > 0:
		audio_stream_player.play()
		
	for nw_tile in new_indicated_tiles:
		var indicator: ResourceIndicator = resource_indicator_scene.instantiate()
		add_child(indicator)
		indicator.global_position = nw_tile * grid_manager.TILE_SIZE
		tile_to_resource_indicator[nw_tile] = indicator
	
	for remove_tile in to_remove_tiles:
		var ind := tile_to_resource_indicator.get(remove_tile, null) as ResourceIndicator
		print(ind)
		if ind and is_instance_valid(ind):
			ind.destroy()
		tile_to_resource_indicator.erase(remove_tile)

func handle_resource_tile_update() -> void:
	var current_resource_tiles = grid_manager.get_collected_resource_tiles()
	
	var newly_indicated_tiles: Array[Vector2i] = []
	for tile in current_resource_tiles:
		if indicated_tiles.has(tile): continue
		newly_indicated_tiles.append(tile)
		
	
	var to_remove_tiles: Array[Vector2i] = []
	for tile in indicated_tiles:
		if not current_resource_tiles.has(tile):
			to_remove_tiles.append(tile)
	indicated_tiles = current_resource_tiles.duplicate()
	update_indicator(newly_indicated_tiles, to_remove_tiles)

func _on_resource_tiles_updated(cant: int) -> void:
	var func_call: Callable = handle_resource_tile_update
	func_call.call_deferred()


 
