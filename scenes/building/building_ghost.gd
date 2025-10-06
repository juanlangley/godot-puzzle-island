extends Node2D
class_name BuildingGhost

@onready var top_left: Node2D = $TopLeft
@onready var top_right: Node2D = $TopRight
@onready var bottom_right: Node2D = $BottomRight
@onready var bottom_left: Node2D = $BottomLeft
@onready var up_down_root: Node2D = %UpDownRoot
@onready var sprite_root: Node2D = $SpriteRoot

var sprite_tween: Tween

func _ready() -> void:
	var up_down_tween = create_tween()
	up_down_tween.set_loops(0)
	up_down_tween.tween_property(up_down_root, "position", Vector2.DOWN * 6, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	up_down_tween.tween_property(up_down_root, "position", Vector2.UP * 6, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func set_invalid() -> void:
	modulate = Color.RED
	up_down_root.modulate = modulate

func set_valid() -> void:
	modulate = Color.WHITE
	up_down_root.modulate = modulate

func set_dimensions(dimensions: Vector2i) -> void:
	bottom_left.position = dimensions * Vector2i(0, 64)
	bottom_right.position = dimensions * Vector2i(64, 64)
	top_right.position = dimensions * Vector2i(64, 0)

func add_sprite_node(sprite_node: Node2D) -> void:
	up_down_root.add_child(sprite_node)

func do_hover_animation() -> void:
	if sprite_tween != null and sprite_tween.is_valid():
		sprite_tween.kill()
	sprite_tween = create_tween()
	sprite_tween.tween_property(sprite_root, "global_position", global_position, 0.3 ).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
