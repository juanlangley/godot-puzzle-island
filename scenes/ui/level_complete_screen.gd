extends Node
@onready var next_level_button: Button = %NextLevelButton
@export_file("*.tscn") var main_menu_scene_path: String

func _ready() -> void:
	AudioHelpers.play_victory() 
	var buttons: Array[Button] = [next_level_button]
	AudioHelpers.register_buttons(buttons)
	
	if LevelManager.is_last_level():
		next_level_button.text = "Return to Menu"


func _on_next_level_button_pressed() -> void:
	if !LevelManager.is_last_level():
		LevelManager.change_to_next_level()
	else:
		get_tree().change_scene_to_file(main_menu_scene_path)
