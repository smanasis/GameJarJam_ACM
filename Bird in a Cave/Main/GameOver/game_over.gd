extends Control



func _ready() -> void:
	#get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS



func _on_restart_pressed():
	$ClickButtom.play()
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Main/Gameplay/main.tscn")



func _on_menu_pressed() -> void:
	$ClickButtom.play()
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Main/Menu/menu.tscn")
