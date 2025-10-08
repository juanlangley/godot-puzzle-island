extends Node

@onready var main_menu_cointainer: MarginContainer = %MainMenuCointainer
@onready var level_select_screen: MarginContainer = %LevelSelectScreen
@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var option_button: Button = %OptionButton

@export var options_menu_scene: PackedScene
var options_menu: OptionsMenu

func _ready() -> void:
	level_select_screen.visible = false
	main_menu_cointainer.visible = true
	level_select_screen.back_press_event.connect(on_level_select_back_pressed)
	var array_button: Array[Button] = [play_button, quit_button, option_button]
	AudioHelpers.register_buttons(array_button)

func _on_play_button_pressed() -> void:
	main_menu_cointainer.visible = false
	level_select_screen.visible = true

func on_level_select_back_pressed() -> void:
	level_select_screen.visible = false
	main_menu_cointainer.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_option_button_pressed() -> void:
	main_menu_cointainer.visible = false
	options_menu = options_menu_scene.instantiate()
	add_child(options_menu)
	options_menu.back_to_menu_signal.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	options_menu.queue_free()
	main_menu_cointainer.visible = true
