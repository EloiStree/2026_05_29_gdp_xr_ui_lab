class_name UiLabClipboardImport
extends Node

signal on_clipboard_import_request(text:String)
signal on_clipboard_import_request_changed(text:String)
signal on_url_detected_on_last_import(url:String)

@export var last_clipboard_imported:String

func import_from_clipboard():
	var clipboard_text :String= DisplayServer.clipboard_get()
	if clipboard_text != last_clipboard_imported:
		last_clipboard_imported = clipboard_text
		on_clipboard_import_request_changed.emit( clipboard_text)
	on_clipboard_import_request.emit(clipboard_text)
	var t = clipboard_text.strip_edges()
	if t.begins_with("http://") or t.begins_with("https://"):
		on_url_detected_on_last_import.emit(t)

	
	
