class_name UiLabLookForTarget
extends Node

signal on_target_changed(node:Node)

@export var found_target: Node
## Look for exact name
@export var node_exact_name:String ="MainTarget"
## If not found by name look for group
@export var group_name:String= "main_target"



func _ready() -> void:
	on_target_changed.emit(null)
	_target_monitor()


func _target_monitor() -> void:
	while true:
		if found_target == null or !is_instance_valid(found_target):
			var looked=_find_target()
			if looked!=found_target:
				found_target=looked
				on_target_changed.emit(found_target)
		await get_tree().create_timer(1.0).timeout


func _find_target() -> Node:
	var target :Node= get_tree().root.find_child(node_exact_name,true, false)
	if target:
		return target
		
	var targets := get_tree().get_nodes_in_group(group_name)
	if not targets.is_empty():
		return targets[0]

	return _find_ui_lab_main_target(get_tree().current_scene)


func _find_ui_lab_main_target(node: Node) -> Node:
	if node is UiLabMainTargetInScene:
		var target_holder:UiLabMainTargetInScene= node
		return target_holder.get_target()

	for child in node.get_children():
		var result := _find_ui_lab_main_target(child)
		if result:
			return result

	return null
