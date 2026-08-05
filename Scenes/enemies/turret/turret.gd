class_name Turret extends Enemy

@onready var gun_muzzle: Marker2D = $GunMuzzle
@onready var detection_component: DetectionComponent = $DetectionComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox
@onready var bullet_scene: PackedScene = preload("uid://bp2owoisgrnuf")

const GUN_MUZZLE_OFFSET: int = 8
const FOLLOW_GIVEUP_DISTANCE: float = 100.0

@export_category("Physics")
@export var gravity: float = 980

@export_category("Follow")
@export var follow_speed: float = 50.0

var is_following: bool = false
var is_dead: bool = false


func _ready() -> void:
	apply_level_difficulty()
	detection_component.player_entered.connect(_on_player_entered)
	detection_component.player_exited.connect(_on_player_exited)
	hitbox.take_damage.connect(_on_take_damage)

	direction = 1.0


func _process(delta: float) -> void:
	if is_dead:
		return
	set_direction()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	_handle_following()

	move_and_slide()


func _on_take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount

	sprite.modulate = Color(1, 0, 0)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

	if current_health <= 0:
		die()


func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	KillManager.register_kill(PlayerManager.player)

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()


func set_direction() -> void:
	if not is_following:
		return

	var previous_direction: float = direction
	super.set_direction()

	if direction != 0 and direction != previous_direction:
		animation_player.play("turn")


func _handle_following() -> void:
	if is_following and PlayerManager.player != null:
		var distance_x: float = PlayerManager.player.global_position.x - global_position.x
		if abs(distance_x) > FOLLOW_GIVEUP_DISTANCE:
			is_following = false

	if is_following and direction != 0 and not is_ledge_ahead():
		velocity.x = direction * follow_speed
	else:
		velocity.x = move_toward(velocity.x, 0, follow_speed)


func _on_player_entered() -> void:
	if is_dead:
		return

	is_following = true
	if bullets.get_children().size() < 3:
		shoot()


func _on_player_exited() -> void:
	pass


func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	var bullet_position: Vector2 = gun_muzzle.global_position

	gun_muzzle.position.x = -GUN_MUZZLE_OFFSET if direction < 0 else GUN_MUZZLE_OFFSET

	if bullets:
		bullets.call_deferred("add_child", bullet)
		bullet.direction = direction
		bullet.global_position = bullet_position
