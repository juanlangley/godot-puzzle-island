extends CanvasLayer

@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var margin_container: MarginContainer = $MarginContainer
@export_file("*.tscn") var main_menu_scene_path: String
@export var options_menu_scene: PackedScene
var options_menu: OptionsMenu
const ESCAPE_ACTION: StringName = "escape"

func _ready() -> void:
	var buttons: Array[Button] = [resume_button,options_button,quit_button]
	AudioHelpers.register_buttons(buttons)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ESCAPE_ACTION):
		queue_free()
		get_viewport().set_input_as_handled()

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)

func _on_resume_button_pressed() -> void:
	queue_free()

func _on_options_button_pressed() -> void:
	margin_container.visible = false
	options_menu = options_menu_scene.instantiate()
	add_child(options_menu)
	options_menu.back_to_menu_signal.connect(_on_options_back_pressed)

func _on_options_back_pressed() -> void:
	margin_container.visible = true
	options_menu.queue_free()
