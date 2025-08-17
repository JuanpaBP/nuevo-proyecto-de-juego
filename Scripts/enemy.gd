extends Area2D

var speed = 100 # Enemy movement speed (pixels per second)
var player_node: Node = null # Reference to the player node
var hp = 100

signal defeated

# A boolean to store whether the enemy should be chasing the player.
# We will use this later if we add another enemy type.
var is_chasing = true

@onready var rober_sprite = $Sprite2D
var sprite_right = preload("res://Assets/Rober_right.png")
var sprite_left = preload("res://Assets/Rober_left.png")


var push_factor = 3000.0 # Magic number to calculate push force.
var max_push_speed = 50.0



func _ready():
	print("Enemy spawned at: ", global_position)

	# Find the player node using its full scene path.
	player_node = get_node("/root/Game/Player")

	if player_node == null:
		print("ERROR: Player node 'Player' not found by enemy at path '/root/Game/Player'!")
		print("Please ensure your main scene's root is named 'Game' and your player node is named 'Player'.")

func _process(delta):
	# This is a non-physics based process function.
	# It's called every frame, so we use it for our movement logic.
	# Only chase if the player node exists and is_chasing is true
	_apply_soft_collision()
	if player_node != null and is_chasing:
		# Calculate the direction vector from the enemy to the player
		var direction_to_player = (player_node.global_position - global_position).normalized()

		# Move the enemy directly by updating its position
		position += direction_to_player * speed * delta
		if direction_to_player.x > 0:
			rober_sprite.texture = sprite_right
		elif direction_to_player.x < 0:
			rober_sprite.texture = sprite_left

# --- Function: Handling Projectile Hits ---
# This function is still called by the Projectile when it hits this enemy.
func take_hit():
	hp = hp - 20
	 # Debugging print
	if(hp <= 0):
		print("Enemy is dead, removing it from scene")
		defeated.emit()
		queue_free() # Remove the enemy from the scene
		
func _remove_from_scene():
	queue_free()

func _apply_soft_collision():
	var overlapping_enemies = get_overlapping_areas()
	for area in overlapping_enemies:
		#Make sure we're not checking against ourselves (?
		if area == self or not area.is_in_group("enemies"):
			continue
		
		
		#Distance between 2 enemies
		var distance_vector = global_position - area.global_position
		var distance = distance_vector.length()
		
		#If they are very close, push them away
		if distance < 40.0: #Magic number, this should be adjusted
			print("Distance is less than 40, entering...")
			var push_direction = distance_vector.normalized()
			print("Push direction is ", push_direction)
			#The more overlapped they are, the more force the push has.
			var push_force = 40.0 - distance
			print("Push force is ", push_force)
	
			var total_push = push_direction * push_force * push_factor * get_process_delta_time()
			print("Total push is ", total_push)
			total_push = total_push.limit_length(max_push_speed)
			print("Total push after limit is: ", total_push)
			global_position += total_push * 0.5
			area.global_position -= total_push * 0.5
