extends MarginContainer

signal back_press_event()
@export var level_select_section_scene: PackedScene
@onready var grid_container: GridContainer = %GridContainer

func _ready() -> void:
	
	var level_definitions = LevelManager.get_level_definitions()
	var index = 0
	for level_definition in level_definitions:
		var level_select_section = level_select_section_scene.instantiate()
		grid_container.add_child(level_select_section)
		level_select_section.set_level_definition(level_definition)
		level_select_section.set_level_index(index)
		level_select_section.level_selected_event_handler.connect(_on_level_selected)
		index += 1

func _on_level_selected(level_index: int) -> void:
	LevelManager.change_to_level(level_index)

func _on_back_button_pressed() -> void:
	back_press_event.emit()
