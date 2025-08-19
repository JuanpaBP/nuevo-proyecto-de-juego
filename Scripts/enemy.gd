extends CharacterBody2D

var speed = 100 # Enemy movement speed (pixels per second)
var player_node: Node = null # Reference to the player node
var hp = 100

signal defeated

# A boolean to store whether the enemy should be chasing the player.
# We will use this later if we add another enemy type.
var is_chasing = true

@onready var rober_sprite = $Sprite

var sprite_right = preload("res://Assets/Rober_right.png")
var sprite_left = preload("res://Assets/Rober_left.png")

func _ready():
	print("Enemy spawned at: ", global_position)

	# Find the player node using its full scene path.
	player_node = get_node("/root/Game/Player")

	if player_node == null:
		print("ERROR: Player node 'Player' not found by enemy at path '/root/Game/Player'!")
		print("Please ensure your main scene's root is named 'Game' and your player node is named 'Player'.")

func _process(delta):
	
	if player_node != null and is_chasing:
		# Calculate the direction vector from the enemy to the player
		var direction_to_player = (player_node.global_position - global_position).normalized()
		# We use physics to move the enemy now, so we use the direction to the player * speed, 
		# to get speed, and we add push_velocity to keep the bouncing effect
		velocity = direction_to_player * speed
		# Move but physics based
		move_and_slide()
		
		if direction_to_player.x > 0:
			rober_sprite.texture = sprite_right
		elif direction_to_player.x < 0:
			rober_sprite.texture = sprite_left

# --- Function: Handling Projectile Hits ---
# This function is still called by the Projectile when it hits this enemy.
func take_hit():
	hp = hp - 20
	if(hp <= 0):
		print("Enemy is dead, removing it from scene")
		defeated.emit()
		_remove_from_scene() # Remove the enemy from the scene
		
func _remove_from_scene():
	queue_free()
