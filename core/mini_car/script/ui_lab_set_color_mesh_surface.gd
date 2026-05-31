class_name  UiLabSetColorMeshSurface
extends Node


@export var target:MeshInstance3D
@export var using_duplicate:bool=true

func set_color(color:Color):
	var mat :StandardMaterial3D = target.get_surface_override_material(0)
	if using_duplicate:
		mat = mat.duplicate()
	mat.albedo_color = color
	target.set_surface_override_material(0,mat)
	
