extends Area2D

var speed = 100 # Enemy movement speed (pixels per second)
var player_node: Node = null # Reference to the player node
var hp = 100

# A boolean to store whether the enemy should be chasing the player.
# We will use this later if we add another enemy type.
var is_chasing = true

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
	if player_node != null and is_chasing:
		# Calculate the direction vector from the enemy to the player
		var direction_to_player = (player_node.global_position - global_position).normalized()

		# Move the enemy directly by updating its position
		position += direction_to_player * speed * delta

# --- Function: Handling Projectile Hits ---
# This function is still called by the Projectile when it hits this enemy.
func take_hit():
	print("Enemy hit! Removing enemy.")
	hp = hp - 20
	 # Debugging print
	if(hp <= 0):
		queue_free() # Remove the enemy from the scene
