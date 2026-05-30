class_name UiLabStaticMapToDoubleColor
extends Node

signal on_left_sensor_updated(color:Color)
signal on_right_sensor_updated(color:Color)

@export var left_sensor_anchor:Node3D
@export var right_sensor_anchor:Node3D

@export var color_left:Color
@export var color_right:Color


func _process(delta: float) -> void:
	color_left = UiLabQuadNodeToSurfaceColor.get_color_at_from_singleton(left_sensor_anchor.global_position)
	on_left_sensor_updated.emit(color_left)
	color_right =UiLabQuadNodeToSurfaceColor.get_color_at_from_singleton(right_sensor_anchor.global_position)
	on_right_sensor_updated.emit(color_right)
