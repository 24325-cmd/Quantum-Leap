extends Node
## One-shot tutorial/lore hint messages shown via the player's message popup.

var coin_hint_shown: bool = false
var kill_hint_shown: bool = false
var agamemnon_hint_shown: bool = false


func show_coin_hint(player: Player) -> void:
	if coin_hint_shown:
		return
	coin_hint_shown = true
	player.show_message("Collect 10 coins to unlock Double Jump")


func show_kill_hint(player: Player) -> void:
	if kill_hint_shown:
		return
	kill_hint_shown = true
	player.show_message("Kill 10 enemies to unlock Cyclops Fire")


func maybe_show_agamemnon_hint(player: Player, force: bool = false) -> void:
	if agamemnon_hint_shown:
		return
	if force or randf() < 0.5:
		agamemnon_hint_shown = true
		player.show_message("You'll need Double Jump and Cyclops Fire to defeat Doom")
