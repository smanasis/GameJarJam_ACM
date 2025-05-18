extends CharacterBody2D


@onready var bat = $DamageDetection/Bat
@export var Bird :Node2D
@onready var main = get_node("/root/Main")

var game_over_scene:= preload("res://Main/GameOver/game_over.tscn")

var bird_position := Vector2.ZERO
var speed = 100
var follow_bird:bool = true
var direction : Vector2

func _ready() -> void:
	bat.play("default")
	#connect("body_entered", _on_body_entered)

func _process(delta: float) -> void:
	if $WingsFlap.playing == false:
		$WingsFlap.play()

func _physics_process(delta: float) -> void:
	if follow_bird:
		direction = (Bird.global_position - global_position).normalized()
	elif follow_bird == false:
		direction = Vector2(-1, 0)
	velocity = direction * speed
	move_and_slide()



func _on_follow_bird_timer_timeout() -> void:
	follow_bird = false


func _on_destroy_itself_timer_timeout() -> void:
	queue_free()


func _on_damage_detection_body_entered(body: Node2D) -> void:
	if body.has_method("rotation_bird_right") or body.get_name() == "LeftCollide":
		$GameOver.play()
		get_tree().paused = true
		#await get_tree().create_timer(1.0).timeout  # wait 1 second
		#get_tree().change_scene_to_file("res://Main/GameOver/game_over.tscn")
		var game_over = game_over_scene.instantiate()
		game_over.set_as_top_level(true)  # Optional: to float on top of UI
		#game_over.process_mode = Node.PROCESS_MODE_ALWAYS  # So the UI still works
		game_over.position = Vector2(-540,-365)#Vector2(-540, 365)
		main.add_child(game_over)
