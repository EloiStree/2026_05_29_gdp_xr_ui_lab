class_name UiLabIfRedTeleportTo
extends Node

@export var target_to_teleport:Node3D
@export var where_to_teleport:Node3D

func check_color(color:Color):
	if color.r>0.9 and color.g<0.3 and color.b<0.3:
		target_to_teleport.global_position = where_to_teleport.global_position
		
