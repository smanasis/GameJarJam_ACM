extends CharacterBody2D

signal bird_position(position)
signal flash_timer_label(remaining_time:float)

const speed = 150.0
const flyingPower = -500.0


# Rotation variables
var max_down_rotation = deg_to_rad(30)    # Slight upward tilt# Facing straight down
var max_up_rotation = deg_to_rad(-70)     # Facing straight down
var rotation_speed = 5.0                  # How fast rotation changes
var target_rotation:float 

#mostly flags
var last_direction:int =-1
var is_alive:bool = true
var die_animation:bool = true
var timer_started:bool = false
var death_sound:bool = true

#flash variables
const FLASH_DISTANCE = 100.0
var can_flash = true


#@onready var flash_cooldown_label = $FlashCooldownLabel
@onready var bird = $AnimationPlayer
@onready var main = get_node("/root/Main")
var game_over_scene:= preload("res://Main/GameOver/game_over.tscn")


func _ready() -> void:
	bird.play("fly")
	death_sound = true

func _process(delta: float) -> void:
	
	emit_signal("bird_position", position)
	
	if !is_alive and death_sound:
		$GameOver.play()
		death_sound = false
	
	if $WingsFlap.playing == false:
		$WingsFlap.play()
	
	if is_on_floor():
		global_rotation = deg_to_rad(0)
		velocity.x = 0
		
	if is_on_floor() and die_animation:
		is_alive = false
		if die_animation:
			bird.play("die")
		die_animation = false
	
	if is_alive == false and timer_started == false:
		$DieFromSpikes.start()
		timer_started = true
	
	
	if !can_flash:
		# Update the label to show the remaining time
		var remaining_time = $FlashCooldown.time_left
		#flash_cooldown_progress.value = progress
		emit_signal("flash_timer_label", remaining_time)#$FlashCooldown.wait_time)
		#flash_cooldown_label.text = "Cooldown: " + str(remaining_time).substr(0, 3) + "s"
	
	#if can_flash:
		#flash_cooldown_label.text = "Ready!"

func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	#variables to handle the direction that the bird looks and identify the last seen direction
	var direction:int = 0
	
	
	if Input.is_action_pressed("right"):
		direction += 1
		last_direction = 1
	elif Input.is_action_pressed("left"):
		direction -= 1
		last_direction = -1
	
	
	if not is_on_floor() and last_direction == -1 and is_alive:
		rotation_bird_left(delta)
	elif not is_on_floor() and last_direction == 1 and is_alive:
		rotation_bird_right(delta)
	
	#flash
	if Input.is_action_just_pressed("flash") and can_flash and is_alive:
		flash()

	
	# Handle jump.
	if Input.is_action_just_pressed("flying") and not is_on_floor() and is_alive:
		velocity.y = flyingPower
		target_rotation = lerp(max_up_rotation, max_down_rotation, clamp(velocity.y / 500.0, 0.0, 1.0))
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		#rotation = lerp(rotation, max_down_rotation, delta * rotation_speed)
		#	rotation = lerp(rotation, max_up_rotation, delta * rotation_speed)
	
	
	if is_alive and not is_on_floor():
		velocity.x = direction * speed
	
	move_and_slide()


#Responsible for flipping sprite and rotate ont the right side
func rotation_bird_right(delta):
	# Rotate depending on vertical speed
	$Sprite2D.flip_h = true
	target_rotation = lerp(max_up_rotation, max_down_rotation, clamp(velocity.y / 500.0, 0.0, 1.0))
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)


#Responsible for flipping sprite and rotate ont the left side
func rotation_bird_left(delta):
	$Sprite2D.flip_h = false
	target_rotation = lerp(max_down_rotation, max_up_rotation, clamp(velocity.y / 500.0, 0.0, 1.0))
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)


func _on_area_2d_body_entered(body: Node2D) -> void:
	bird.stop()
	is_alive = false
	velocity.x = 0


func _on_die_from_spikes_timeout() -> void:
	get_tree().paused = true
	var game_over = game_over_scene.instantiate()
	game_over.set_as_top_level(true)  # Optional: to float on top of UI
	#game_over.process_mode = Node.PROCESS_MODE_ALWAYS  # So the UI still works
	game_over.position = Vector2(-540,-365)#Vector2(-540, 365)
	main.add_child(game_over)


func flash():
	var flash_direction
	if rotation == 0 and $Sprite2D.flip_h == true:
		flash_direction = Vector2(1, 0)
	elif rotation == 0 and $Sprite2D.flip_h == false:
		flash_direction = Vector2(-1, 0)
	elif $Sprite2D.flip_h == true:
		# Use the bird's rotation to calculate the direction vector
		flash_direction = Vector2.RIGHT.rotated(rotation).normalized()
	elif $Sprite2D.flip_h == false:
		flash_direction = Vector2.LEFT.rotated(rotation).normalized()
	
	var target_position = position + flash_direction * FLASH_DISTANCE
	
	# Create the raycast parameters
	var ray_params = PhysicsRayQueryParameters2D.create(position, target_position)
	ray_params.exclude = [self]  # Exclude the bird itself
	# Do the raycast
	var space_state = get_world_2d().direct_space_state
	var ray_result = space_state.intersect_ray(ray_params)
	if ray_result:
		# Obstacle detected, stop just before the hit point
		target_position = ray_result.position - flash_direction * 4
	
	position = target_position
	
	# Start cooldown
	can_flash = false
	$FlashCooldown.start()


func _on_flash_cooldown_timeout() -> void:
	can_flash = true
