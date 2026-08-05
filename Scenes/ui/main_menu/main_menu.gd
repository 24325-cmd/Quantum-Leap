class_name MainMenu extends Control

@onready var button_container: VBoxContainer = $CanvasLayer/ButtonContainer
@onready var tutorial_check_box: CheckBox = $CanvasLayer/ButtonContainer/TutorialCheckBox


func _on_start_button_pressed() -> void:
	var target_path: String = LevelManager.DEMO_LEVEL_PATH if tutorial_check_box.button_pressed else LevelManager.STARTING_LEVEL_PATH
	get_tree().change_scene_to_file(target_path)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
