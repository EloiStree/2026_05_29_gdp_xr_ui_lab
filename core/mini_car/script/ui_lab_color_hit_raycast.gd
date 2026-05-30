@tool
class_name UiLabMaterialColorHitRaycast
extends RayCast3D

signal on_mesh_albedo_color_updated(color: Color)
signal on_mesh_geometry_color_updated(color: Color)
signal on_mesh_surface_color_updated(color: Color)
signal on_mesh_any_material_color_updated(color: Color)
signal on_color_updated(color: Color)

@export var last_color: Color = Color.RED
@export var last_mesh_color: Color = Color.RED
@export var last_geometry_color: Color = Color.RED
@export var last_surface_color: Color = Color.RED

@export var no_color_found_value: Color = Color(0, 0, 0, 0)
@export var ray_cast: RayCast3D

var _debug_marker: MeshInstance3D = null
var _texture_image_cache: Dictionary = {}


func _ready() -> void:
	if ray_cast == null:
		ray_cast = self

	on_color_updated.emit(last_color)


func _physics_process(_delta: float) -> void:
	if ray_cast == null or not ray_cast.is_colliding():
		_reset_no_collision()
		return

	var collider := ray_cast.get_collider()
	if collider == null:
		_update_color(no_color_found_value)
		return

	# Try to resolve MeshInstance3D properly
	var mesh_instance: MeshInstance3D = null

	if collider is MeshInstance3D:
		mesh_instance = collider
	elif collider is Node3D:
		# common case: MeshInstance is parent or sibling
		mesh_instance = collider.get_parent() as MeshInstance3D

	if mesh_instance == null:
		_update_color(no_color_found_value)
		return

	var hit_point := ray_cast.get_collision_point()
	var hit_uv: Vector2 = ray_cast.get_collision_uv()

	_update_debug_marker(hit_point)

	# Get material safely
	var material := mesh_instance.get_active_material(0)
	if material == null:
		_update_color(no_color_found_value)
		return

	if material is BaseMaterial3D:
		_process_base_material(material, hit_uv)
	elif material is ShaderMaterial:
		_process_shader_material(material)
	else:
		_update_color(Color.WHITE)


func _process_base_material(material: BaseMaterial3D, hit_uv: Vector2) -> void:
	var final_color := material.albedo_color

	if material.albedo_texture:
		var image := _get_texture_image(material.albedo_texture)

		if image:
			var tex_size := Vector2i(image.get_width(), image.get_height())

			var pixel_pos := Vector2i(
				int(hit_uv.x * tex_size.x),
				int(hit_uv.y * tex_size.y)
			)

			pixel_pos = pixel_pos.clamp(Vector2i.ZERO, tex_size - Vector2i.ONE)

			final_color *= image.get_pixelv(pixel_pos)

	last_mesh_color = final_color
	last_surface_color = final_color

	on_mesh_albedo_color_updated.emit(final_color)
	on_mesh_surface_color_updated.emit(final_color)

	_update_color(final_color)


func _process_shader_material(material: ShaderMaterial) -> void:
	var color_param: Variant = material.get_shader_parameter("albedo")

	if color_param == null:
		color_param = material.get_shader_parameter("color")

	if color_param == null:
		color_param = material.get_shader_parameter("albedo_color")

	if not (color_param is Color):
		color_param = Color.WHITE

	last_geometry_color = color_param

	on_mesh_geometry_color_updated.emit(color_param)
	_update_color(color_param)


func _update_color(color: Color) -> void:
	# FIX: must update last_color before compare logic becomes useful
	if color.is_equal_approx(last_color):
		return

	last_color = color

	on_mesh_any_material_color_updated.emit(color)
	on_color_updated.emit(color)


func _reset_no_collision() -> void:
	_clear_debug_marker()

	if not last_color.is_equal_approx(no_color_found_value):
		last_color = no_color_found_value
		on_color_updated.emit(last_color)


func _get_texture_image(texture: Texture2D) -> Image:
	if texture == null:
		return null

	var key := texture.get_instance_id()

	if _texture_image_cache.has(key):
		return _texture_image_cache[key]

	var image := texture.get_image()
	if image:
		if image.is_compressed():
			image.decompress()

		_texture_image_cache[key] = image

	return image


func _update_debug_marker(position: Vector3) -> void:
	if _debug_marker:
		_debug_marker.global_position = position


func _clear_debug_marker() -> void:
	if _debug_marker:
		_debug_marker.global_position = Vector3(9999, 9999, 9999)


func clear_texture_cache() -> void:
	_texture_image_cache.clear()


func _exit_tree() -> void:
	clear_texture_cache()

	if _debug_marker:
		_debug_marker.queue_free()
