extends Node


func _ready() -> void:
	pass 



func _on_next_level_button_pressed() -> void:
	LevelManager.change_to_next_level()
