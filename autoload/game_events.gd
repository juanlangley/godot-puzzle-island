extends Node

signal building_placed_event_handler(building_component: BuildingComponent)
signal building_destroyed_event_handler(building_component: BuildingComponent)
signal building_disabled_event_handler(building_component: BuildingComponent)
signal building_enabled_event_handler(building_component: BuildingComponent)

func _ready() -> void:
	pass # Replace with function body.
