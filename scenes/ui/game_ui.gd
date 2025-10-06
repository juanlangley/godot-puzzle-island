extends CanvasLayer
class_name GameUI
#@onready var place_tower_button: Button = %PlaceTowerButton
#@onready var place_village_button: Button = %PlaceVillageButton
@onready var building_section_container: VBoxContainer = %BuildingSectionContainer
@onready var resource_label: Label = %ResourceLabel
@export var building_resources: Array[BuildingResource]
@export var building_manager: BuildingManager
signal building_resource_selected_event(building_resource: BuildingResource)
const BUILDING_SELECTION = preload("uid://edoto0i0e5w1")

#signal place_tower_button_pressed_event
#signal place_village_button_pressed_event

func _ready() -> void:
	create_building_sections()
	building_manager.available_resource_count_changed.connect(_on_available_resource_count_changed)

func hide_UI() -> void:
	visible = false

func create_building_sections() -> void:
	for buld_resource in building_resources:
		var building_selection: BuildingSelection = BUILDING_SELECTION.instantiate()
		building_section_container.add_child(building_selection)
		building_selection.set_building_resource(buld_resource)
		building_selection.select_button.pressed.connect(func(): building_resource_selected_event.emit(buld_resource))

func _on_available_resource_count_changed(available_resouces_count: int) -> void:
	resource_label.text = "%d" % available_resouces_count

#func _on_place_tower_button_pressed() -> void:
	#place_tower_button_pressed_event.emit()

#func _on_place_village_button_pressed() -> void:
	#place_village_button_pressed_event.emit()
