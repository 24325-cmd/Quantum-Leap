extends Node
## Tracks coins collected. Separate from KillManager, which tracks a
## different bar filled by enemy kills.

signal ability_unlocked(ability: Ability)

enum Ability { DOUBLE_JUMP }

const COINS_REQUIRED: int = 10

var coins_collected: int = 0
var unlocked_abilities: Dictionary = {Ability.DOUBLE_JUMP: false}


func initialize(player: Player) -> void:
	player.xp_bar.max_value = COINS_REQUIRED

	if unlocked_abilities[Ability.DOUBLE_JUMP]:
		player.has_double_jump = true
		player.xp_bar.value = COINS_REQUIRED
		return

	coins_collected = 0
	player.xp_bar.value = 0


func register_coin_collected(player: Player) -> void:
	if unlocked_abilities[Ability.DOUBLE_JUMP]:
		return

	coins_collected += 1
	player.xp_bar.value = coins_collected

	if coins_collected >= COINS_REQUIRED:
		unlocked_abilities[Ability.DOUBLE_JUMP] = true
		apply_ability_to_player(player, Ability.DOUBLE_JUMP)
		ability_unlocked.emit(Ability.DOUBLE_JUMP)


func apply_ability_to_player(player: Player, ability: Ability) -> void:
	match ability:
		Ability.DOUBLE_JUMP:
			player.has_double_jump = true
			player.player_camera.configure_shake(Utils.ShakeType.BIG)
			player.player_camera.add_trauma(0.4)
			player.show_message("Double Jump Unlocked!")
