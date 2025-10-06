extends Camera2D

const PAN_SPEED := 500
const ACTION_PAN_LEFT: StringName = "pan_left"
const ACTION_PAN_RIGHT: StringName = "pan_right"
const ACTION_PAN_UP: StringName = "pan_up"
const ACTION_PAN_DOWN: StringName = "pan_down"
const TILE_SIZE := 64

func _process(delta: float) -> void:
	global_position = get_screen_center_position()
	var movement_vector = Input.get_vector(ACTION_PAN_LEFT, ACTION_PAN_RIGHT, ACTION_PAN_UP, ACTION_PAN_DOWN)
	global_position += movement_vector * PAN_SPEED * delta

func set_bounding_rect(bounding_rect: Rect2i):
	limit_left = bounding_rect.position.x * TILE_SIZE
	limit_right = bounding_rect.end.x * TILE_SIZE
	limit_top = bounding_rect.position.y * TILE_SIZE
	limit_bottom = bounding_rect.end.y * TILE_SIZE


func center_on_position(position: Vector2) -> void:
	global_position = position
