class_name  UiLabSetColorMeshSurface
extends Node


@export var target:MeshInstance3D

func set_color(color:Color):
	var mat :StandardMaterial3D = target.get_surface_override_material(0)
	mat.albedo_color = color
	target.set_surface_override_material(0,mat)
	
