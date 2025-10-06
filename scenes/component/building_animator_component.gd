extends Node2D
class_name BuildingAnimatorComponent

signal destroy_animation_finished()

@export var mask_texture: Texture2D
@export var impact_particules_scene: PackedScene
@export var destroy_particules_scene: PackedScene
var active_tween: Tween
var animation_root_node: Node2D
var mask_node: Sprite2D

func _ready() -> void:
	y_sort_enabled = false
	setup_nodes()


func play_in_animation() -> void:
	if animation_root_node == null: return
	if active_tween!= null and active_tween.is_valid():
		active_tween.kill()
	
	var func_callable: Callable = func():
		var impact_particles: Node2D = impact_particules_scene.instantiate()
		owner.get_parent().add_child(impact_particles)
		impact_particles.global_position = global_position
		
	active_tween = create_tween()
	active_tween.tween_property(animation_root_node, "position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).from(Vector2.UP * 128)
	active_tween.tween_callback(func_callable)
	active_tween.tween_property(animation_root_node, "position", Vector2.UP * 16, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(animation_root_node, "position", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	

func play_destroy_animation() -> void:
	if animation_root_node == null: return
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	
	animation_root_node.position = Vector2.ZERO
	
	mask_node.texture = mask_texture
	mask_node.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	
	var destroy_particles: Node2D = destroy_particules_scene.instantiate()
	owner.get_parent().add_child(destroy_particles)
	destroy_particles.global_position = global_position
	
	active_tween = create_tween()
	active_tween.tween_property(animation_root_node, "rotation_degrees", -5, 0.1)
	active_tween.tween_property(animation_root_node, "rotation_degrees", 5, 0.1)
	active_tween.tween_property(animation_root_node, "rotation_degrees", -2, 0.1)
	active_tween.tween_property(animation_root_node, "rotation_degrees", 2, 0.1)
	active_tween.tween_property(animation_root_node, "rotation_degrees", 0, 0.1)
	
	active_tween.tween_property(animation_root_node, "position", Vector2.DOWN * 300, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	active_tween.finished.connect(func(): destroy_animation_finished.emit())

func setup_nodes() -> void:
	var sprite_node: Array[Node]= get_children()
	if sprite_node.is_empty(): return
	var unique_sprite_node: Node2D = sprite_node[0] as Node2D
	remove_child(unique_sprite_node)
	position = Vector2(unique_sprite_node.position.x, unique_sprite_node.position.y)
	
	mask_node = Sprite2D.new()
	mask_node.centered = false
	mask_node.offset = Vector2(-160, -256)
	
	add_child(mask_node)
	
	animation_root_node = Node2D.new()
	mask_node.add_child(animation_root_node)
	animation_root_node.add_child(unique_sprite_node)
	unique_sprite_node.position = Vector2(0, 0)
