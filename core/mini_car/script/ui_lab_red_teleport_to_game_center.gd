class_name UiLabRedTeleportToGameCenter
extends Node


@export var where_to_teleport:Node3D
@export var what_to_teleport:Node3D
@export var height_offset_if_not_where_to_teleport:Vector3=Vector3(0,0.1,0)

@export var threshold_red:float=0.8
@export var threshold_green_blue:float=0.2

func check_color(color:Color):
	if color.r>threshold_red and color.g<threshold_green_blue and color.b<threshold_green_blue:
		if where_to_teleport:
			what_to_teleport.global_position = where_to_teleport.position
		else:
			what_to_teleport.global_position =height_offset_if_not_where_to_teleport
