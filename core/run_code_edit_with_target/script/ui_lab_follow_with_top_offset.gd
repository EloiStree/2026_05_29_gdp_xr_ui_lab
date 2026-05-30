extends Node

@export var what_to_follow:Node3D
@export var what_to_move:Node3D

func _process(delta: float) -> void:
	what_to_move.global_position = what_to_follow.global_position 
	what_to_move.global_rotation  =what_to_follow.global_rotation
	
