extends Node2D
class_name GoldMine

@export var active_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D


func set_active() -> void:
	sprite.texture = active_texture
