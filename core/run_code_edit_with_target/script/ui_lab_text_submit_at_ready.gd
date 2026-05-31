## I am class that trigger a text at ready to be used.
class_name UiLabTextSubmitAtReady
extends Node

signal on_text_submit(text:String)
@export var use_at_ready:bool=true

@export_multiline() 
var text:String

func _ready() -> void:
	if use_at_ready:
		on_text_submit.emit(text)

	
