class_name uiLabSubViewGetColor
extends Node
@export var viewport :SubViewport
@export var mesh_target:MeshInstance3D
@export var material :StandardMaterial3D

func _ready():
	if not viewport or not mesh_target or not material:
		push_error("Missing required exports: viewport, mesh_target, or material")
		return
	
	await get_tree().process_frame
	
	var tex = viewport.get_texture()
	if not tex:
		push_error("Failed to get texture from viewport")
		return
	
	material.albedo_texture = tex
	mesh_target.set_surface_override_material(0, material)
	
