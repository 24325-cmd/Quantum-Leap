extends Node
## Tracks enemy kills, separate from XPManager's coin bar.
## Filling it (10 kills) unlocks Cyclops Fire for the player, once.

signal skill_unlocked

const KILLS_REQUIRED: int = 10

var kills: int = 0
var is_skill_unlocked: bool = false


func initialize(player: Player) -> void:
	player.kill_bar.max_value = KILLS_REQUIRED

	if is_skill_unlocked:
		player.has_cyclops_fire = true
		player.kill_bar.value = KILLS_REQUIRED
		return

	kills = 0
	player.kill_bar.value = 0


func register_kill(player: Player) -> void:
	if is_skill_unlocked:
		return

	kills += 1
	player.kill_bar.value = kills

	HintManager.show_kill_hint(player)

	if kills >= KILLS_REQUIRED:
		unlock_skill(player)


func unlock_skill(player: Player) -> void:
	is_skill_unlocked = true
	player.has_cyclops_fire = true
	player.player_camera.configure_shake(Utils.ShakeType.BIG)
	player.player_camera.add_trauma(0.4)
	player.show_message("Cyclops Fire Unlocked!")
	skill_unlocked.emit()
