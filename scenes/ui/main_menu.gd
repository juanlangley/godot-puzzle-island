extends Node

@onready var main_menu_cointainer: MarginContainer = %MainMenuCointainer
@onready var level_select_screen: MarginContainer = %LevelSelectScreen

func _ready() -> void:
	level_select_screen.visible = false
	main_menu_cointainer.visible = true
	level_select_screen.back_press_event.connect(on_level_select_back_pressed)


func _on_play_button_pressed() -> void:
	main_menu_cointainer.visible = false
	level_select_screen.visible = true

func on_level_select_back_pressed() -> void:
	level_select_screen.visible = false
	main_menu_cointainer.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()
