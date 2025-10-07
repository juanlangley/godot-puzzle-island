extends Node2D
class_name ResourceIndicator

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
var active_tween: Tween

func _ready() -> void:
	var duration = randf_range(0.5, 0.55)
	active_tween = create_tween()
	active_tween.set_loops()
	active_tween.tween_property(animated_sprite_2d, "position", Vector2.UP * 4, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(animated_sprite_2d, "position", Vector2.DOWN * 4, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func destroy() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.set_parallel()
	active_tween.tween_interval(randf_range(0.1, 0.3))
	active_tween.chain()
	active_tween.tween_property(animated_sprite_2d, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	active_tween.tween_property(animated_sprite_2d, "position", Vector2.UP * 32, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	active_tween.chain()
	active_tween.tween_callback(func(): queue_free())
