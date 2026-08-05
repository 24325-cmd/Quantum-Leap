class_name JumpState extends State

@onready var fall_state: FallState = $"../FallState"
@onready var knockback_state: Knockbackstate = $"../KnockbackState"
@onready var attack_state: AttackState = $"../AttackState"


# what happens when we enter the state
func enter() -> void:
	player.jump_audio.play()
	player.velocity.y = player.jump_force
	player.animation_player.play("jump")

	if player.is_on_floor():
		get_tree().create_timer(0.2).timeout.connect(func(): player.can_double_jump = true)


func exit() -> void:
	pass


# called every frame during _process
func process(delta: float) -> State:
	return null


# called every physics frame during _physics_process 
func physics(delta: float) -> State:
	if player.direction:
		player.velocity.x = lerp(
			player.velocity.x, player.direction * player.air_speed, player.air_acceleration
		)
	else :
		player.velocity.x = lerp(player.velocity.x, 0.0, player.air_acceleration * 0.5)

	if player.velocity.y >= 0:
		return fall_state

	if player.is_knocked_back:
		return knockback_state

	return null


# called when input events occur
func unhandled_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump"):
		if player.has_double_jump and player.can_double_jump and not player.is_on_floor():
			player.can_double_jump = false
			player.velocity.y = player.jump_force
			player.jump_audio.play()
			return self
	if event.is_action_pressed("attack"):
		return attack_state
	return null
