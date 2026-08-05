extends Node

signal level_load_started
signal level_lead_finished

const DEMO_LEVEL_PATH: String = "res://Scenes/levels/levels/demo.tscn"
const STARTING_LEVEL_PATH: String = "res://Scenes/levels/levels/test_scene.tscn"
const MAIN_MENU_PATH: String = "res://Scenes/ui/main_menu/main_menu.tscn"

var current_level: Level
var next_level: Level
var checkpoint_level_path: String = STARTING_LEVEL_PATH


func set_checkpoint(level_path: String) -> void:
	checkpoint_level_path = level_path


func _ready() -> void:
	await get_tree().process_frame
	level_load_started.emit()


func change_level(level_path: String) -> void:
	if not is_valid_level_path(level_path):
		return

	get_tree().paused = true
	level_load_started.emit()
	await SceneTransition.fade_out()

	if PlayerManager.player and PlayerManager.player.get_parent():
		PlayerManager.player.get_parent().remove_child(PlayerManager.player)
		PlayerManager.player.reset_for_new_level()

	for child in get_tree().root.get_children():
		if child is Level:
			child.queue_free()

	await get_tree().process_frame

	next_level = load_new_level(level_path)
	if not next_level:
		printerr("Failed to load level: ", level_path)
		get_tree().paused = false
		return

	add_new_level()
	await SceneTransition.fade_in()

	get_tree().paused = false
	level_lead_finished.emit()


func is_valid_level_path(level_path: String) -> bool:
	if not level_path or not FileAccess.file_exists(level_path):
		printerr("Invalid level path: ", level_path)
		return false
	return true


func load_new_level(level_path: String) -> Level:
	var level_scene = load(level_path) as PackedScene
	if not level_scene:
		return null

	var instance = level_scene.instantiate() as Level
	if not instance:
		return null

	return instance


func add_new_level() -> void:
	get_tree().root.add_child(next_level)
	current_level = next_level


func restart_current_level() -> void:
	if current_level:
		change_level(current_level.scene_file_path)


func go_to_main_menu() -> void:
	get_tree().paused = false
	DeathMenu.visible = false
	WinMenu.visible = false

	if PlayerManager.player and PlayerManager.player.get_parent():
		PlayerManager.player.get_parent().remove_child(PlayerManager.player)

	for child in get_tree().root.get_children():
		if child is Level:
			child.queue_free()

	current_level = null
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
