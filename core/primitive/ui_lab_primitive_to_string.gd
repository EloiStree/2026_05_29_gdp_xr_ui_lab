class_name UiLabPrimitiveToString
extends Node

signal on_primitive_parsed(text: String)

@export var last_converted: String

@export var true_as_text: String = "1"
@export var false_as_text: String = "0"

@export var float_format: String = "{:.2f}"
@export var float_format_vector: String = "{:.1f}"
@export var float_format_quaternion: String = "{:.1f}"


func relay_text(text: String) -> void:
	last_converted = text
	on_primitive_parsed.emit(text)


func relay_bool(value: bool) -> void:
	relay_text(true_as_text if value else false_as_text)


func relay_int(value: int) -> void:
	relay_text(str(value))


func relay_float(value: float) -> void:
	relay_text(float_format.format(value))


func _float_to_format(value: float, format: String) -> String:
	return format.format(value)
	

func relay_vector2(value: Vector2) -> void:
	relay_text("(%s, %s)" % [
		_float_to_format(value.x, float_format_vector),
		_float_to_format(value.y, float_format_vector)
	])


func relay_vector3(value: Vector3) -> void:
	relay_text("(%s, %s, %s)" % [
		_float_to_format(value.x, float_format_vector),
		_float_to_format(value.y, float_format_vector),
		_float_to_format(value.z, float_format_vector)
	])


func relay_vector4(value: Vector4) -> void:
	relay_text("(%s, %s, %s, %s)" % [
		_float_to_format(value.x, float_format_vector),
		_float_to_format(value.y, float_format_vector),
		_float_to_format(value.z, float_format_vector),
		_float_to_format(value.w, float_format_vector)
	])


func relay_quaternion(value: Quaternion) -> void:
	relay_text("(%s, %s, %s, %s)" % [
		_float_to_format(value.x, float_format_quaternion),
		_float_to_format(value.y, float_format_quaternion),
		_float_to_format(value.z, float_format_quaternion),
		_float_to_format(value.w, float_format_quaternion)
	])


func relay_vector2i(value: Vector2i) -> void:
	relay_text("(%d, %d)" % [value.x, value.y])


func relay_vector3i(value: Vector3i) -> void:
	relay_text("(%d, %d, %d)" % [value.x, value.y, value.z])


func relay_array_variable(value: Array) -> void:
	relay_text(str(value))