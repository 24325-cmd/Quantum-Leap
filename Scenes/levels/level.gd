class_name Level extends Node2D

const DEMO_PATH: String = "res://Scenes/levels/levels/demo.tscn"
const LEVEL1_PATH: String = "res://Scenes/levels/levels/test_scene.tscn"
const LEVEL2_PATH: String = "res://Scenes/levels/levels/level01.tscn"
const LEVEL3_PATH: String = "res://Scenes/levels/levels/level02.tscn"
const LEVEL4_PATH: String = "res://Scenes/levels/levels/level03.tscn"
const LEVEL5_PATH: String = "res://Scenes/levels/levels/level04.tscn"
const LEVEL6_BOSS_PATH: String = "res://Scenes/levels/levels/level05 BOSS FIGHT.tscn"

const STAGE_TITLES: Dictionary = {
	LEVEL1_PATH: "Stage 1",
	LEVEL2_PATH: "Stage 2",
	LEVEL3_PATH: "Stage 3",
	LEVEL4_PATH: "Stage 4",
	LEVEL5_PATH: "Stage 5",
	LEVEL6_BOSS_PATH: "The End of Times",
}

## Extra hit points added to regular enemies (Cyborg/Turret) per level, so
## later stages take more hits to clear. The boss sets its own health directly
## and ignores this.
const DIFFICULTY_BONUS: Dictionary = {
	LEVEL1_PATH: 0,
	LEVEL2_PATH: 1,
	LEVEL3_PATH: 2,
	LEVEL4_PATH: 3,
	LEVEL5_PATH: 4,
	LEVEL6_BOSS_PATH: 0,
}

static func get_difficulty_bonus(level_path: String) -> int:
	return DIFFICULTY_BONUS.get(level_path, 0)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#1a1226"))

	add_child(PlayerManager.player)
	PlayerManager.player.global_position = %PlayerSpawn.global_position
	PlayerManager.player.player_camera.setup_camera_limits()

	LevelManager.set_checkpoint(scene_file_path)

	if STAGE_TITLES.has(scene_file_path):
		PlayerManager.player.show_stage_title(STAGE_TITLES[scene_file_path])

	match scene_file_path:
		DEMO_PATH:
			_run_onboarding()
		LEVEL1_PATH:
			HintManager.show_coin_hint(PlayerManager.player)
		LEVEL2_PATH:
			HintManager.maybe_show_agamemnon_hint(PlayerManager.player)
		LEVEL3_PATH:
			HintManager.maybe_show_agamemnon_hint(PlayerManager.player, true)


func _run_onboarding() -> void:
	var player: Player = PlayerManager.player
	if not player:
		return

	player.set_hud_bars_visible(false)

	await get_tree().create_timer(0.5).timeout
	player.show_persistent_message("Use AD / Arrow Keys to Move")
	var keys_used: Dictionary = {}
	while keys_used.size() < 2:
		await get_tree().process_frame
		if Input.is_action_just_pressed("left"):
			keys_used["left"] = true
		if Input.is_action_just_pressed("right"):
			keys_used["right"] = true
	player.hide_persistent_message()

	await get_tree().create_timer(0.3).timeout
	player.show_persistent_message("Press W / Space to Jump")
	while not Input.is_action_just_pressed("jump"):
		await get_tree().process_frame
	player.hide_persistent_message()

	await get_tree().create_timer(0.3).timeout
	player.show_persistent_message("Use Left Mouse Button to Hit the Enemy")
	var enemy: Node = get_node_or_null("Enemy")
	if enemy:
		await enemy.tree_exited
	player.hide_persistent_message()

	await get_tree().create_timer(0.3).timeout
	player.show_message("Onboarding Complete!")
	await get_tree().create_timer(2.0).timeout

	player.set_hud_bars_visible(true)
	LevelManager.change_level(LEVEL1_PATH)
