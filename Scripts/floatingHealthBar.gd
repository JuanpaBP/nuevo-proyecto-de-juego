extends Node2D

@onready var progress_bar = $ProgressBar # Get a reference to the ProgressBar child
var hide_timer = 0.0
var hide_delay = 3.0 # Seconds before hiding after no damage
var is_critical = false # Flag to keep it always visible if health is critical


func _ready():
	#Hide the bar from the get go
	visible = false

func _process(delta):
	#Only tick the timer if health is not critical and currently visible
	if not is_critical and visible:
		hide_timer -= delta
		if hide_timer <= 0:
			visible = false #Hide the hp bar

func update_health(current_health: float, max_health: float):
	progress_bar.max_value = max_health
	progress_bar.value =current_health
	visible = true # Show when updated
	
	#Check if health is critical
	is_critical = (current_health / max_health) <= 0.1
	
	#Reset timer if not critical health
	if not is_critical:
		hide_timer = hide_delay
	else:
		#If critical, keep it visible by not letting the time hide it
		visible = true
