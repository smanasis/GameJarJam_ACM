extends Node2D


#signal speed_up_spawnning

var score: float = 0
var score_multiplier:float = 100.0
var multiplier_increase_rate: float = 5.0  # How fast the score speed grows
var max_multiplier: float = 1000.0  # Optional: cap the score speed

@onready var score_label = $ScoreLabel
@onready var flash_cooldown_label = $FlashCooldownLabel
#@onready var FLASH_COOLDOWN_TIME:float = $FlashCooldownLabel/FlashCooldownBar.max_value


func _ready() -> void:
	get_tree().paused = false
	score = 0
	#process_mode = Node.PROCESS_MODE_ALWAYS



func _process(delta: float) -> void:
	score_multiplier += multiplier_increase_rate * delta
	score_multiplier = min(score_multiplier, max_multiplier)  # Clamp it if needed
	score += score_multiplier * delta
	score_label.text = "Score: %d" % score
	
	#if score == 5000:
		#emit_signal("speed_up_spawnning")
	
	if $Soundtrack.playing == false:
		$Soundtrack.play()




func _on_bird_flash_timer_label(remaining_time: float) -> void:
		$FlashCooldownLabel.text = "Flash: " + str(remaining_time).substr(0, 3) + "s"
		#var percentage = 1.0 - clamp(remaining_time / FLASH_COOLDOWN_TIME, 0.0, 1.0)
		#$FlashCooldownLabel/FlashCooldownBar.value = percentage
		#try to make progression bar
		
		#if remaining_time <= 0.0:
			#$FlashCooldownLabel.text = "Flash: Ready!"
