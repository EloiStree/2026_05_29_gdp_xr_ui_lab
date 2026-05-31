## I am class that trigger a text at ready to be used.
class_name UiLabTextSubmitAtReady
extends Node

signal on_text_submit(text:String)

@export_multiline() 
var text:String

func _ready() -> void:
	on_text_submit.emit(text)

	
