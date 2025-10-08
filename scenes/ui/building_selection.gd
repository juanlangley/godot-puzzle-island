extends PanelContainer
class_name BuildingSelection


@onready var select_button: Button = %Button
@onready var title_label: Label = %TitleLabel
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel

func _ready() -> void:
	var buttons: Array[Button] = [select_button]
	AudioHelpers.register_buttons(buttons)


func set_building_resource(building_resource: BuildingResource) -> void:
	title_label.text = building_resource.display_name
	cost_label.text = "%d" % building_resource.resource_cost
	description_label.text = building_resource.description
