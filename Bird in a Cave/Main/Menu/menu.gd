extends Node2D


func _ready() -> void:
	get_tree().paused = false
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#$ClickButtom.pause_mode = 2



func _on_play_pressed() -> void:
	$ClickButtom.play()
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Main/Gameplay/main.tscn")
