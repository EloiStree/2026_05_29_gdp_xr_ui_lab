class_name UiLabColorBulletSpawner
extends Node

@export var bullet_scene: PackedScene
@export var spawn_point: Node3D
@export var speed_in_meter: float = 10.0
@export var max_bullets: int = 3

# NEW: fire delay (seconds between shots)
@export var fire_delay: float = 0.25

var bullets: Array[Node3D] = []

# NEW: internal cooldown timer
var _cooldown: float = 0.0


func _process(delta: float) -> void:
	# update cooldown
	if _cooldown > 0.0:
		_cooldown -= delta

	# Move all active bullets
	for i in range(bullets.size()):
		var b: Node3D = bullets[i]
		if b == null:
			continue

		var forward: Vector3 = -b.global_transform.basis.z
		b.global_position += forward.normalized() * speed_in_meter * delta


func fire() -> void:
	# NEW: block firing if still in cooldown
	if _cooldown > 0.0:
		return

	if bullet_scene == null or spawn_point == null:
		return

	# reset cooldown
	_cooldown = fire_delay

	# Limit max bullets
	if bullets.size() >= max_bullets:
		_remove_oldest_bullet()

	var bullet: Node3D = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.show()

	bullet.global_position = spawn_point.global_position
	bullet.global_rotation = spawn_point.global_rotation

	bullets.append(bullet)


func _remove_oldest_bullet() -> void:
	if bullets.is_empty():
		return

	var old_bullet: Node3D = bullets.pop_front()
	if old_bullet != null:
		old_bullet.queue_free()
