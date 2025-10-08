extends Node

@onready var game_camera: Camera2D = $GameCamera
@onready var grid_manager: GridManager = $GridManager
@onready var gold_mine: GoldMine = %GoldMine
@onready var base_terrain_tile_map_layer: TileMapLayer = %BaseTerrainTileMapLayer
@onready var base: Node2D = %Base
@export var level_complete_screen_scene: PackedScene
@onready var game_ui: GameUI = $GameUI
@export var level_definition_resource: LevelDefinitionResource
@onready var building_manager: BuildingManager = $BuildingManager
@export var escape_menu_scene: PackedScene

const ESCAPE_ACTION: StringName = "escape"

func _ready() -> void:
	grid_manager.grid_state_updated_event_handler.connect(_on_grid_state_updated)
	
	building_manager.set_starting_resource_count(level_definition_resource.starting_resource_count)
	
	game_camera.set_bounding_rect(base_terrain_tile_map_layer.get_used_rect())
	game_camera.center_on_position(base.global_position)
	game_ui.visible = true
	
	grid_manager.set_gold_mine_position(grid_manager.convert_world_position_to_tile_position(gold_mine.global_position))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ESCAPE_ACTION):
		var escape_menu = escape_menu_scene.instantiate()
		add_child(escape_menu)
		get_viewport().set_input_as_handled()

func _on_grid_state_updated() -> void:
	var gold_mine_tile_position = grid_manager.convert_world_position_to_tile_position(gold_mine.global_position)
	if grid_manager.is_tile_position_in_any_building_radius(gold_mine_tile_position):
		var level_complete_screen = level_complete_screen_scene.instantiate()
		add_child(level_complete_screen)
		gold_mine.set_active()
		game_ui.hide_UI()
