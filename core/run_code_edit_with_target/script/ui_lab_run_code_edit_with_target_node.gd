## I am a class that allows modding from a code editor in a game and that focus a target Node to communicate with.
class_name UiLabRunCodeEditWithTargetNode
extends Control


## The place for the player to write code to be run when requested.
@export var _code_edit:CodeEdit

## I am a variable holding the button to run the code of the player.
@export var _run_button:Button
## I am a variable holding the button to stop the code of the player.
@export var _stop_button:Button

## The node to target for the running code of the player in the exercice
@export var _target_node:Node

## Method to call on the player code to provide him target and new target.
@export var _method_to_notify_new_target:String="_on_received_target"



func _ready() -> void:
	if _run_button:
		_run_button.button_down.connect(reload_code_from_code_edit)
	if _stop_button:
		_stop_button.button_down.connect(unload_current_code)

#region Target

##  Allows the developer to set the target node to play with from the player running code.
func set_target_node(node:Node):
	_target_node = node
	_notify_to_created_node_the_target()
	

## Private code to transmit the player the node he can use to interact with the exercice.
## It call a method in the player code if it exist to give him the target node.
func _notify_to_created_node_the_target():
	if _created_node_holding_code and _created_node_holding_code.has_method(_method_to_notify_new_target):
		_created_node_holding_code.call(_method_to_notify_new_target, _target_node)
#endregion


#region Code Editor

##  Set the text in the Godot Code editor but dont reload the running code
## it allows the use to choose when he want to offciialy reload
func set_code_in_code_edit_without_reload(text:String):
	_code_edit.text= text

## set the text in the Godot Code editor then relaod the code
func set_code_in_code_edit_and_reload(text:String):
	_code_edit.text= text
	reload_code_from_code_edit()

## Take the code of the code editor and reload the code.
func reload_code_from_code_edit():
	var code :String = _code_edit.text
	load_and_run_text_as_godot_script(code)
#endregion
	

#region CALL METHOD 
## Example of how you can call a method on the target node if it exist.
func call_method_in_target_if_existing(method_name:String):
	if _target_node and _target_node.has_method(method_name):
		_target_node.call(method_name)
	
## Example of how you can call a method with a single parameter on the target node if it exists.
func call_method_in_target_if_existing_with_one_parameter(method_name:String, parameter:Variant):
	if _target_node and _target_node.has_method(method_name):
		_target_node.call(method_name, parameter)
			
## Example of how you can call a method with an array of parameters on the target node if it exists.
func call_method_in_target_if_existing_with_array_of_parameters(method_name:String, parameters:Array[Variant]):
	if _target_node and _target_node.has_method(method_name):
		_target_node.call(method_name, parameters)
#endregion
			
			
## -------------------------------------------
			
#region CONNECT TO SIGNAL

## Example of how you can connect a signal if it exist on the target node.
func connect_if_signal_with_exist(signal_name:String, callable):
	if _target_node and _target_node.has_signal(signal_name):
		_target_node.connect(signal_name,callable)
		
## Example of how you can disconnect a signal if it exist on the target node.
func disconnect_if_signal_with_exist(signal_name:String,callable):
	if _target_node and _target_node.has_signal(signal_name):
		_target_node.disconnect(signal_name,callable)
#endregion


## -------------------------------------------

#region SET VARIABLE

## Is the target has the variable with the name given ?
func is_target_has_variable(variable_name:String)->bool:
	return _target_node and has_property_of_node(_target_node, variable_name)

## Allows to set the variable of the target script if it exist.
func set_variable_of_target_if_existing(variable_name:String, value:Variant):
	if _target_node and is_target_has_variable(variable_name):
		_target_node.set(variable_name,value) 


static func has_property_of_node(node: Node, property_name: String) -> bool:
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true
	return false

#endregion
			
## -------------------------------------------


#region CHILD UTILITY

## I am a method that get all the children recusrively in the target note.
## It allows to search for a node with a specific trait in the children of the target node for example.
func get_all_childrens_recursive_of_target()->Array[Node]:
	return get_all_nodes_in_childrens_recursive_from(_target_node)
	

## I am a method that get all the children not recusrively in the target note.
## It allows to search for a node with a specific trait in the direct children of the target node for example.
func get_all_childrens_not_recursive_of_target()->Array[Node]:
	return get_all_childrens_not_recusively_from(_target_node)
	

## I am a method that find the first child with a specific name in the target node.
func find_first_children_with_name(name:String)->Node:
	if _target_node:
		return _target_node.find_child(name,true, false)
	return null
	
## I am a method that find the first child with a specific group in the target node.
static func get_all_childrens_not_recusively_from(node:Node) -> Array[Node]:
	var result:Array[Node] = []
	result.append(node)
	for child in node.get_children():
		result.append(child)
	return result

## I am a method that get all the children recusrively in a node.
static func get_all_nodes_in_childrens_recursive_from(node:Node)->Array[Node]:
	var result:Array[Node] = []
	var queue:Array[Node] = [node]
	while queue.size() > 0:
		var current = queue.pop_front()
		for child in current.get_children():
			result.append(child)
			queue.append(child)	
	return result
	
#endregion



## -------------------------------------------

#region MODDING
#region LOAD CODE


## I am signal that warn the developer that the node holding the player code is about to be destroy. 
signal on_destroy_previous_node_holding_code_start(node:Node)

## I am signal that warn the developer that the node holding the player code is now destroy.
signal on_destroy_previous_node_holding_code_end()

## I am signal that warn the developer that a new node holding the player code is now created.
signal on_created_node(node_created:Node)

## I am signal that warn the developer that the code of the player was not loadable.
signal on_fail_to_load_code(code:String)



@export_group("Modding")
## I am a varible  of the node where the player code is run.	
@export var _where_to_run_code:Node
## I am a variable to set the name of the file where the code of the player will be store in user://.
@export var _unique_code_file_name:String ="code_edit_file.gd"

## I am a variable that give the designer the choose if the node created must be 3D
@export var _create_node_as_node_3d:bool=false

@export_group("Modding/Debug")	
## I am a variable that hold the node created with the player code.
@export var _created_node_holding_code:Node


## Allows to set or reparent where the Node with the running code need to be hosted.
func set_where_to_run_code(node:Node):
	_where_to_run_code=node
	if _created_node_holding_code:
		_created_node_holding_code.reparent(_where_to_run_code,true)

## Allows to warn developers and destroy the node running the code.
func unload_current_code():
	on_destroy_previous_node_holding_code_start.emit(_created_node_holding_code)
	if _created_node_holding_code:
		## if it existe. kill it. I means... lets is free 
		_created_node_holding_code.queue_free()
		_created_node_holding_code = null
	on_destroy_previous_node_holding_code_end.emit()		


## I am the method that load the text given as code of the player to run as Godot script in a new node.
func load_and_run_text_as_godot_script(code:String):
	
	## When we start we need to destroy the previous one.
	unload_current_code()
	## code cant be loaded like that. you need to load from file
	## we can create the file in folde of our application
	var script_path: String = "user://"+_unique_code_file_name
	## print(script_path)
	## to see where it is store in the end
	print(ProjectSettings.globalize_path(script_path))
	var file_connection =FileAccess.open(script_path, FileAccess.WRITE)
	if file_connection:
		file_connection.store_string(code)
		file_connection.close()
	else:
		push_error("File was not created")
		return
	
	# lets try to execute it now.
	var script: Script = ResourceLoader.load(
		script_path,
		"GDScript",
		ResourceLoader.CACHE_MODE_IGNORE
	)

	if not script is GDScript:
		push_error("That not a Godot Script")
		on_fail_to_load_code.emit(code)
		return
	
	## we need for that a node
	var node :Node =  Node3D.new() if _create_node_as_node_3d else Node.new()
	# we have a new node but not yet in the scene
	node.set_script(script)
	# he has our code 
	node.set_process(true)
	# he now use _process(delta)
	node.set_physics_process(true)
	# in case we need it later
	
	## now we add it in the scene
	_created_node_holding_code = node
	if _where_to_run_code:
		_where_to_run_code.add_child(node)
	else:
		add_child(node)
	_notify_to_created_node_the_target()
	on_created_node.emit(node)
	
#endregion

#endregion


#region ADDITIONAL CODE



func has_code_running()->bool:
	return _created_node_holding_code != null

func has_target_node()->bool:
	return _target_node != null

func has_target_node_and_code_running()->bool:
	return has_target_node() and has_code_running()


func get_holding_code_node()->Node:
	return _created_node_holding_code

func get_target_node()->Node:
	return _target_node





#endregion
