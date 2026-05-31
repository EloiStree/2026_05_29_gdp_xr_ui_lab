class_name UiLabSingletonInGameTarget
extends Node

static var in_game_targets: Array[Node] = []
static var on_target_updated: Array[Callable] = []

@export var target_to_add_at_singleton: Node


static func add_listener(callback: Callable) -> void:
	if not callback.is_valid():
		return

	on_target_updated.append(callback)

	# Immediately notify with current target
	callback.call(get_first_target())


static func remove_listener(callback: Callable) -> void:
	if not callback.is_valid():
		return

	callback.call(null)
	on_target_updated.erase(callback)


func _notify_update() -> void:
	var target := get_first_target()

	for callback in on_target_updated:
		if callback.is_valid():
			callback.call(target)


func _enter_tree() -> void:
	if target_to_add_at_singleton:
		in_game_targets.append(target_to_add_at_singleton)

	_notify_update()


func _exit_tree() -> void:
	if target_to_add_at_singleton:
		in_game_targets.erase(target_to_add_at_singleton)

	_notify_update()


static func has_target() -> bool:
	return get_first_target() != null


static func get_first_target() -> Node:
	for target in in_game_targets:
		if is_instance_valid(target):
			return target

	return null
