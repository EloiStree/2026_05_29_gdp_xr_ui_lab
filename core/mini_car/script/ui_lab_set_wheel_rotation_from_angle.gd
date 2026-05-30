class_name UiLabSetWheelRotationFromAngle
extends Node
@export var _pivot_to_rotate_localy:Node3D
@export var _current_angle:float 
@export var _bool_inverse:bool

func set_current_angle_and_update(rotation_angle_in_degree:float):
	_current_angle= rotation_angle_in_degree
	var multi = -1 if _bool_inverse else 1
	_pivot_to_rotate_localy.rotation_degrees = Vector3(-_current_angle*multi,0,0)
	
