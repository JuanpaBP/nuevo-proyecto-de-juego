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

# Variables for the bouncing of each other
var push_factor = 4000.0 # Magic number to calculate push force.
var max_push_speed = 50.0
var push_velocity = Vector2.ZERO

@onready var soft_collision_area = $Area2D

func _ready():
	print("Enemy spawned at: ", global_position)

	# Find the player node using its full scene path.
	player_node = get_node("/root/Game/Player")

	if player_node == null:
		print("ERROR: Player node 'Player' not found by enemy at path '/root/Game/Player'!")
		print("Please ensure your main scene's root is named 'Game' and your player node is named 'Player'.")

func _process(delta):
	_apply_soft_collision()
	if player_node != null and is_chasing:
		# Calculate the direction vector from the enemy to the player
		var direction_to_player = (player_node.global_position - global_position).normalized()
		# We use physics to move the enemy now, so we use the direction to the player * speed, 
		# to get speed, and we add push_velocity to keep the bouncing effect
		var final_velocity = direction_to_player * speed + push_velocity
		if final_velocity.length() > speed + max_push_speed:
			final_velocity = final_velocity.normalized() * (speed + max_push_speed)
		velocity = final_velocity
		# Move but physics based
		move_and_slide()
		
		# Smoothing push velocity
		push_velocity = push_velocity.move_toward(Vector2.ZERO, delta * 1000)
		
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

func _apply_soft_collision():
	var overlapping_enemies = soft_collision_area.get_overlapping_areas()
	for area in overlapping_enemies:
		if area.get_parent() == self:
			continue
		
		var distance_vector = global_position - area.global_position
		var distance = distance_vector.length()
		
		if distance < 40.0:
			var push_direction = distance_vector.normalized()
			var push_force = 40.0 - distance
	
			var total_push = push_direction * push_force * push_factor * get_physics_process_delta_time()
			total_push = total_push.limit_length(max_push_speed)
			
			push_velocity += total_push * 0.5
			if area.get_parent().has_method("apply_push"):
				area.get_parent().apply_push(-total_push * 0.5)
			else:
				print("ERROR: Other enemy does not have 'apply_push' method!")

# --- Function to apply push from other enemies. ---
func apply_push(push_vector):
	push_velocity += push_vector
