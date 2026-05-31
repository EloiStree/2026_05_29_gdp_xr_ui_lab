class_name UiLabCodeToLoadRelay3D
extends Node3D


signal on_code_to_relay_received(code:String)

@export_multiline() var _code_received:String
@export var _relay_at_read:bool=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _relay_at_read:
		relay_code(_code_received)
	
func relay_code(code:String):
	_code_received = code
	on_code_to_relay_received.emit(_code_received)
