class_name UiLabSubViewToDoubleColor
extends Node

signal on_left_color_updated(color:Color)
signal on_right_color_updated(color:Color)

@export var subviewport: SubViewport
@export var left_pixel:Vector2i = Vector2i(0, 0)
@export var right_pixel:Vector2i = Vector2i(15, 0)

@export var _last_left: Color
@export var _last_right: Color


func _physics_process(_delta: float) -> void:
	if subviewport == null:
		return

	var tex := subviewport.get_texture()
	if tex == null:
		return

	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		return

	var left_pixel: Color = img.get_pixel(left_pixel.x, left_pixel.y)
	var right_pixel: Color = img.get_pixel(right_pixel.x, right_pixel.y)

	_last_left = left_pixel
	_last_right = right_pixel
	on_left_color_updated.emit(left_pixel)
	on_right_color_updated.emit(right_pixel)
