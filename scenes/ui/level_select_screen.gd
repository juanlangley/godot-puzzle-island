extends MarginContainer

signal back_press_event()
@export var level_select_section_scene: PackedScene
@onready var grid_container: GridContainer = %GridContainer
@onready var previous_page_button: Button = %PreviousPageButton
@onready var next_page_button: Button = %NextPageButton
@onready var back_button: Button = %BackButton

const PAGE_SIZE: int = 6
var page_index: int

var level_definitions: Array[LevelDefinitionResource]
var max_page_index: int
func _ready() -> void:
	var buttons: Array[Button] = [previous_page_button, next_page_button, back_button]
	AudioHelpers.register_buttons(buttons)
	
	level_definitions = LevelManager.get_level_definitions()
	max_page_index = level_definitions.size() / PAGE_SIZE
	show_page()


func show_page() -> void:
	update_button_visibility()
	
	for child in grid_container.get_children():
		child.queue_free()
	 
	var start_index = PAGE_SIZE * page_index
	var end_index = minf(start_index + PAGE_SIZE, level_definitions.size()) 
	var index = start_index
	while index < end_index:
	#for level_definition in level_definitions:
		var level_definition = level_definitions[index]
		var level_select_section = level_select_section_scene.instantiate()
		grid_container.add_child(level_select_section)
		level_select_section.set_level_definition(level_definition)
		level_select_section.set_level_index(index)
		level_select_section.level_selected_event_handler.connect(_on_level_selected)
		index += 1

func update_button_visibility() -> void:
	previous_page_button.disabled = page_index == 0
	if page_index == 0:
		previous_page_button.modulate = Color.TRANSPARENT
	else:
		previous_page_button.modulate = Color.WHITE
	
	next_page_button.disabled = page_index == max_page_index
	if page_index == max_page_index:
		next_page_button.modulate = Color.TRANSPARENT
	else:
		next_page_button.modulate = Color.WHITE

func _on_level_selected(level_index: int) -> void:
	LevelManager.change_to_level(level_index)

func _on_back_button_pressed() -> void:
	back_press_event.emit()

func _on_next_page_button_pressed() -> void:
	page_index += 1
	show_page()

func _on_previous_page_button_pressed() -> void:
	page_index -= 1
	show_page()
