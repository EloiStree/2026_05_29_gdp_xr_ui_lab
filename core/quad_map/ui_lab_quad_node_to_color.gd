class_name UiLabQuadNodeToSurfaceColor
extends Node

static var map_in_scene:UiLabQuadNodeToSurfaceColor


static func get_color_at_from_singleton(global_position:Vector3) -> Color:
	if map_in_scene != null:
		return map_in_scene.get_color_of_global_point(global_position)
	return Color(0,0,0,0)

static func set_map_singleton_in_scene(map:UiLabQuadNodeToSurfaceColor) -> void:
	map_in_scene = map


	
func _enter_tree() -> void:
	print("Setting singleton for UiLabQuadNodeToSurfaceColor in scene.",self)
	set_map_singleton_in_scene(self)



signal on_color_left_updated(color: Color)
signal on_color_right_updated(color: Color)

@export var mesh_instance_as_quad: MeshInstance3D

@export var down_left_anchor: Node3D
@export var top_right_anchor: Node3D

@export var width_distance: float
@export var height_distance: float

@export var last_image_refresh: Image

@export var node_left_global: Node3D
@export var node_right_global: Node3D

@export var color_left: Color
@export var color_right: Color




func _ready() -> void:
	
	refresh_distance()

	var material := mesh_instance_as_quad.get_surface_override_material(0)
	if material and material.albedo_texture:
		var texture: Texture2D = material.albedo_texture
		var original_image := texture.get_image()

		if original_image:
			last_image_refresh = original_image.duplicate()
			last_image_refresh.decompress()



	set_map_singleton_in_scene(self)




func _process(_delta: float) -> void:
	refresh_distance()

	if node_left_global:
		color_left = get_color_of_global_point(node_left_global.global_position)
		on_color_left_updated.emit(color_left)

	if node_right_global:
		color_right = get_color_of_global_point(node_right_global.global_position)
		on_color_right_updated.emit(color_right)


func refresh_distance() -> void:
	var local_corner := relocate_point(down_left_anchor, top_right_anchor.global_position)
	width_distance = abs(local_corner.x)
	height_distance = abs(local_corner.z)


func get_color_of_global_point(global_point: Vector3) -> Color:
	if last_image_refresh == null:
		return Color(0,0,0,0)

	var uv := relocate_point_as_percent(down_left_anchor, global_point)

	if uv.x < 0.0 or uv.x > 1.0 or uv.z < 0.0 or uv.z > 1.0:
		return Color(0,0,0,0)

	var w := last_image_refresh.get_width()
	var h := last_image_refresh.get_height()

	var x := clampi(int(uv.x * (w - 1)), 0, w - 1)
	var y := clampi(int(uv.z * (h - 1)), 0, h - 1)

	return last_image_refresh.get_pixel(x, y)


func relocate_point(origin: Node3D, point: Vector3) -> Vector3:
	# Convert world point into anchor-local space (Godot 4 safe)
	return origin.global_transform.basis.inverse() * (point - origin.global_position)


func relocate_point_as_percent(origin: Node3D, point: Vector3) -> Vector3:
	var local := relocate_point(origin, point)

	if width_distance == 0.0 or height_distance == 0.0:
		return Vector3.ZERO

	return Vector3(
		local.x / width_distance,
		local.y,
		local.z / height_distance
	)
