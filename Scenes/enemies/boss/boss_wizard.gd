class_name BossWizard extends Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detection_component: DetectionComponent = $DetectionComponent
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var fire_wall_scene: PackedScene = preload("res://Scenes/enemies/boss/boss_fire_wall.tscn")
@onready var smash_scene: PackedScene = preload("res://Scenes/enemies/boss/boss_smash.tscn")
@onready var health_bar: TextureProgressBar = $BossHealthCanvasLayer/BossHealthBar
@onready var energy_texture: Texture2D = preload("res://Game Assets/fx/explosion spritsheet.png")

@export_category("Physics")
@export var gravity: float = 980
@export var speed: float = 131.25

@export_category("Attack")
@export var attack_cooldown: float = 1.8
@export var attack_range: float = 110.0
@export var melee_range: float = 55.0
@export var fire_wall_offset: float = 35.0
@export var smash_offset: float = 20.0

var is_following: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0


func _ready() -> void:
	max_health = 40
	current_health = 40
	health_bar.max_value = max_health
	health_bar.value = current_health

	detection_component.player_entered.connect(_on_player_entered)
	detection_component.player_exited.connect(_on_player_exited)
	hitbox.take_damage.connect(_on_take_damage)

	direction = -1.0
	is_following = true
	animation_player.play("idle")


func _process(delta: float) -> void:
	if is_dead:
		return

	set_direction()

	if attack_timer > 0.0:
		attack_timer -= delta

	if (
		is_following and not is_attacking and PlayerManager.player != null
		and abs(PlayerManager.player.global_position.x - global_position.x) < attack_range
		and attack_timer <= 0.0
	):
		_attack()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead or is_attacking:
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return

	if is_following and direction != 0:
		velocity.x = direction * speed
		if not animation_player.current_animation == "run":
			animation_player.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if velocity.x == 0 and not animation_player.current_animation == "idle":
			animation_player.play("idle")

	move_and_slide()


func _attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	velocity.x = 0

	var distance: float = abs(PlayerManager.player.global_position.x - global_position.x) \
		if PlayerManager.player else attack_range

	if distance < melee_range:
		animation_player.play("attack2")
		_cast_smash()
	else:
		animation_player.play("attack1")
		_cast_fire_wall()

	await animation_player.animation_finished

	is_attacking = false
	if not is_dead:
		animation_player.play("idle")


func _cast_fire_wall() -> void:
	if is_dead:
		return

	var fire_wall: Node2D = fire_wall_scene.instantiate()
	get_parent().call_deferred("add_child", fire_wall)
	fire_wall.global_position = Vector2(
		global_position.x + fire_wall_offset * direction, global_position.y
	)


func _cast_smash() -> void:
	if is_dead:
		return

	var smash: Node2D = smash_scene.instantiate()
	get_parent().call_deferred("add_child", smash)
	smash.global_position = Vector2(
		global_position.x + smash_offset * direction, global_position.y
	)


func _on_player_entered() -> void:
	if is_dead:
		return
	is_following = true


func _on_player_exited() -> void:
	pass


func _on_take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	health_bar.value = current_health

	sprite.modulate = Color(1, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

	if current_health <= 0:
		die()


func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	hurtbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitorable", false)

	animation_player.play("death")
	_spawn_death_energy()

	var health_tween := create_tween()
	health_tween.tween_property(health_bar, "modulate:a", 0.0, 1.0)

	if PlayerManager.player:
		PlayerManager.player.player_camera.configure_shake(Utils.ShakeType.BIG)
		PlayerManager.player.player_camera.add_trauma(1.0)

	await animation_player.animation_finished

	if PlayerManager.player:
		PlayerManager.player.show_message("Doom Defeated!")
	await get_tree().create_timer(2.3).timeout

	if PlayerManager.player:
		PlayerManager.player.show_message(
			"Coins Collected: %d/%d" % [XPManager.coins_collected, XPManager.COINS_REQUIRED]
		)
	await get_tree().create_timer(2.3).timeout

	if PlayerManager.player:
		PlayerManager.player.show_message(
			"Enemies Defeated: %d/%d" % [KillManager.kills, KillManager.KILLS_REQUIRED]
		)
	await get_tree().create_timer(2.3).timeout

	WinMenu.show_win_screen()
	queue_free()


func _spawn_death_energy() -> void:
	for i in range(6):
		var burst := Sprite2D.new()
		burst.texture = energy_texture
		burst.hframes = 12
		burst.frame = randi() % 12
		burst.scale = Vector2(0.3, 0.3)
		burst.modulate = Color(1, 0.9, 1, 0.9)
		burst.position = Vector2(randf_range(-20, 20), randf_range(-70, -10))
		add_child(burst)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(burst, "position:y", burst.position.y - 45, 1.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(burst, "modulate:a", 0.0, 1.3)
		tween.set_parallel(false)
		tween.tween_callback(burst.queue_free)
