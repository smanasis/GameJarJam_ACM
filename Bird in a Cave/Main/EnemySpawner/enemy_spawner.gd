extends Node2D


@onready var main = get_node("/root/Main")
@export var target:Node2D

var bat_scene:= preload("res://Main/Character/Bat.tscn")
var spawn_points:= []


func _ready() -> void:
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)




func _on_timer_timeout() -> void:
	var spawn = spawn_points[randi() % spawn_points.size()]
	var bat = bat_scene.instantiate()
	bat.Bird = target
	bat.position = spawn.position
	main.add_child(bat)


#func _on_main_speed_up_spawnning() -> void:
	#$Timer.wait_time = 2
