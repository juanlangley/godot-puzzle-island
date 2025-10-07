extends Camera2D
class_name GameCamera

const PAN_SPEED := 500
const ACTION_PAN_LEFT: StringName = "pan_left"
const ACTION_PAN_RIGHT: StringName = "pan_right"
const ACTION_PAN_UP: StringName = "pan_up"
const ACTION_PAN_DOWN: StringName = "pan_down"
const TILE_SIZE := 64
@export var shake_noise: FastNoiseLite

static var instance: GameCamera

const SHAKE_DECAY: float = 3.0
const NOISE_FREQUENCY_MULTIPLIER:float = 100.0
const NOISE_SAMPLE_GROWTH: float = 0.1
const MAX_CAMERA_OFFSET: float = 24.0
var noise_sample: Vector2
var current_shake_percentage: float

func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		instance = self           # se registra al instanciar la escena
	elif what == NOTIFICATION_PREDELETE:
		if instance == self:
			instance = null       # limpieza

static func shake() -> void:
	instance.current_shake_percentage = 1.0


func _process(delta: float) -> void:
	#global_position = get_screen_center_position()
	var movement_vector = Input.get_vector(ACTION_PAN_LEFT, ACTION_PAN_RIGHT, ACTION_PAN_UP, ACTION_PAN_DOWN)
	global_position += movement_vector * PAN_SPEED * delta
	
	var viewport_size = get_viewport_rect()
	var half_width = viewport_size.size.x / 2
	var half_hight = viewport_size.size.y /2
	var x_clamped = clamp(global_position.x, limit_left + half_width, limit_right - half_width)
	var y_clamped = clamp(global_position.y, limit_top + half_hight, limit_bottom - half_hight)
	global_position = Vector2(x_clamped, y_clamped)
	apply_camera_shake(delta)

func set_bounding_rect(bounding_rect: Rect2i):
	limit_left = bounding_rect.position.x * TILE_SIZE
	limit_right = bounding_rect.end.x * TILE_SIZE
	limit_top = bounding_rect.position.y * TILE_SIZE
	limit_bottom = bounding_rect.end.y * TILE_SIZE


func center_on_position(position: Vector2) -> void:
	global_position = position

func apply_camera_shake(delta: float) -> void:
	if (current_shake_percentage > 0):
		noise_sample.x += NOISE_SAMPLE_GROWTH * NOISE_FREQUENCY_MULTIPLIER * delta
		noise_sample.y += NOISE_SAMPLE_GROWTH * NOISE_FREQUENCY_MULTIPLIER * delta
		
		current_shake_percentage = clamp(current_shake_percentage - (SHAKE_DECAY * delta), 0, 1)
	
	var xSample = shake_noise.get_noise_2d(noise_sample.x , 0)
	var ySample = shake_noise.get_noise_2d(0 , noise_sample.y)
	offset = Vector2(MAX_CAMERA_OFFSET * xSample, MAX_CAMERA_OFFSET * ySample) * current_shake_percentage
