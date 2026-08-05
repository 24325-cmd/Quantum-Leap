class_name Enemy extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var bullets: Node = $Bullets
@onready var sprite_scale: float = absf(sprite.scale.x)
@onready var ledge_detector: RayCast2D = $LedgeDetector

@export var face_left: bool = true
@export var ledge_check_distance: float = 8.0

@export_category("Health")
@export var max_health: int = 3
@export var current_health: int = 3

var direction: float


func is_ledge_ahead() -> bool:
	if not ledge_detector or direction == 0:
		return false

	ledge_detector.global_position = global_position + Vector2(ledge_check_distance * sign(direction), 0)
	ledge_detector.force_raycast_update()
	return not ledge_detector.is_colliding()


func apply_level_difficulty() -> void:
	var level := _find_level()
	if not level:
		return

	var bonus: int = Level.get_difficulty_bonus(level.scene_file_path)
	max_health += bonus
	current_health += bonus


func _find_level() -> Node:
	var node: Node = get_parent()
	while node and not (node is Level):
		node = node.get_parent()
	return node


func set_direction() -> void:
	if PlayerManager.player == null:
		return

	var distance_x: float = PlayerManager.player.global_position.x - global_position.x

	if abs(distance_x) < 15.0:
		direction = 0
	elif distance_x > 0:
		direction = 1
	else:
		direction = -1

	if direction != 0:
		sprite.scale.x = (-direction if face_left else direction) * sprite_scale
