extends PanelContainer

@onready var level_number_label: Label = %LevelNumberLabel
@onready var resource_count_label: Label = %ResourceCountLabel
var level_index: int
signal level_selected_event_handler(level_index: int)

func set_level_definition(level_definition_resource: LevelDefinitionResource) -> void:
	resource_count_label.text = "%d" % level_definition_resource.starting_resource_count

func set_level_index(index: int) -> void:
	level_index = index
	level_number_label.text = "Level %d" % (index + 1)


func _on_button_pressed() -> void:
	level_selected_event_handler.emit(level_index)
