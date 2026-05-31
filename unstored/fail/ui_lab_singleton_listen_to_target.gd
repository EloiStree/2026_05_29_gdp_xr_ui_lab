class_name UiLabSingletonListenToTargetInGame
extends Node

signal target_updated(target)

@export var last_target_received: Node


func _enter_tree() -> void:
	UiLabSingletonInGameTarget.add_listener(_target_updated)


func _exit_tree() -> void:
	UiLabSingletonInGameTarget.remove_listener(_target_updated)


func _target_updated(target: Node) -> void:
	last_target_received = target
	target_updated.emit(target)


func get_current_target_received() -> Node:
	return last_target_received
