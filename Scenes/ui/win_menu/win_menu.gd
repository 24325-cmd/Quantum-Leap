extends CanvasLayer


func _ready() -> void:
	visible = false


func show_win_screen() -> void:
	if PlayerManager.player and PlayerManager.player.is_dead:
		return

	DeathMenu.visible = false
	get_tree().paused = true
	visible = true


func _on_home_button_pressed() -> void:
	visible = false
	LevelManager.go_to_main_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
