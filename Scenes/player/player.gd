class_name Player extends CharacterBody2D

signal player_died

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var gun_muzzle: Marker2D = $GunMuzzle
@onready var hitbox: Hitbox = $Hitbox
@onready var jump_audio: AudioStreamPlayer = $Audio/JumpAudio
@onready var shoot_audio: AudioStreamPlayer = $Audio/ShootAudio
@onready var damaged_audio: AudioStreamPlayer = $Audio/DamagedAudio
@onready var knockback_state: Knockbackstate = $StateMachine/KnockbackState
@onready var player_camera: Playercamera = $PlayerCamera
@onready var health_bar: TextureProgressBar = $HealthCanvasLayer/HealthBar
@onready var bullets: Node = $Bullets
@onready var xp_bar: TextureProgressBar = $XPCanvasLayer/XPBar
@onready var kill_bar: TextureProgressBar = $KillCanvasLayer/KillBar
@onready var message_label: Label = $MessageCanvasLayer/MessageLabel
@onready var stage_label: Label = $StageCanvasLayer/StageLabel

@export_category("Physics")
@export var speed: float = 200.0
@export var gravity: float = 980.0
@export var air_speed: float = 150.0
@export var air_acceleration: float = 0.1
@export var jump_force: float = -400.0

@export_category("Attack")
@export var max_bullets: int = 3

@export_category("Abilities")
@export var has_double_jump: bool = false
@export var can_double_jump: bool = false
@export var has_cyclops_fire: bool = false

@export_category("Health")
@export var max_health: int = 5
@export var current_health: int = 5

var direction: float
var is_knocked_back: bool = false
var is_dead: bool = false
var is_invincible: bool = false

const  GUN_MUZZLE_OFFSET: int = 26
const INVINCIBILITY_DURATION: float = 0.6


func _ready() -> void:
	PlayerManager.player = self
	print("Player current health: ", current_health)
	state_machine.configure(self)
	hitbox.take_damage.connect(_on_take_damage)

	health_bar.value = current_health
	health_bar.max_value = max_health

	XPManager.initialize(self)
	KillManager.initialize(self)


func _process(_delta: float) -> void:
	direction = Input.get_axis("left", "right")
	if direction:
		set_player_direction()
	manage_bullets()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_double_jump = has_double_jump

	move_and_slide()


func set_player_direction() -> void:
	sprite.flip_h = direction < 0
	gun_muzzle.position.x = -GUN_MUZZLE_OFFSET if direction < 0 else GUN_MUZZLE_OFFSET

func _on_take_damage(amount: int) -> void:
	if is_dead or is_invincible:
		return

	health_bar.value -= amount
	current_health -= amount

	if current_health <= 0:
		die()
		return

	_start_invincibility()

	if is_knocked_back:
		return


	if amount >= 4:
		player_camera.configure_shake(Utils.ShakeType.EXPLOSION)
		player_camera.add_trauma(1.0)
	elif amount >= 3:
		player_camera.configure_shake(Utils.ShakeType.BIG)
		player_camera.add_trauma(0.8)
	else:
		player_camera.configure_shake(Utils.ShakeType.MEDIUM)
		player_camera.add_trauma(0.6)

	state_machine.change_state(knockback_state)
	print("Player current health: ", current_health)


func _start_invincibility() -> void:
	is_invincible = true

	var blink_tween := create_tween()
	blink_tween.set_loops(3)
	blink_tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	blink_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	get_tree().create_timer(INVINCIBILITY_DURATION).timeout.connect(func():
		is_invincible = false
		sprite.modulate.a = 1.0
	)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_bar.value = current_health


func die() -> void:
	if is_dead:
		return
	is_dead = true
	player_died.emit()


func reset_for_new_level() -> void:
	is_dead = false
	is_invincible = false
	sprite.modulate.a = 1.0
	current_health = max_health
	health_bar.value = current_health


func manage_bullets() -> void:
	for bullet: Bullet in bullets.get_children():
		if abs(bullet.global_position.x - PlayerManager.player.global_position.x) > 500:
			bullet._destroy()


func show_message(text: String) -> void:
	message_label.text = text
	message_label.modulate.a = 0.0
	message_label.scale = Vector2(0.6, 0.6)
	message_label.set("theme_override_constants/outline_size", 2)

	var tween := create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(message_label, "scale", Vector2(1, 1), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.5)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5)

	var glow_tween := create_tween()
	glow_tween.set_loops(3)
	glow_tween.tween_property(message_label, "theme_override_constants/outline_size", 3, 0.3) \
		.set_trans(Tween.TRANS_SINE)
	glow_tween.tween_property(message_label, "theme_override_constants/outline_size", 2, 0.3) \
		.set_trans(Tween.TRANS_SINE)


func set_hud_bars_visible(bars_visible: bool) -> void:
	health_bar.visible = bars_visible
	xp_bar.visible = bars_visible
	kill_bar.visible = bars_visible


func show_persistent_message(text: String) -> void:
	message_label.text = text
	message_label.modulate.a = 0.0
	message_label.scale = Vector2(0.6, 0.6)
	message_label.set("theme_override_constants/outline_size", 2)

	var tween := create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(message_label, "scale", Vector2(1, 1), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_persistent_message() -> void:
	var tween := create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 0.4)


func show_stage_title(text: String) -> void:
	stage_label.text = text
	stage_label.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(stage_label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(stage_label, "modulate:a", 0.0, 0.8)
