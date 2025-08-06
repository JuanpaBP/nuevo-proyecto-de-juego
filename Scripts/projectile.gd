extends Area2D

# Variables for the projectile's behavior
var speed = 400.0 # How fast the projectile moves (pixels per second)
var direction = Vector2(0, 0) # This will be set by the player when it shoots, starts as (0,0)
var lifetime = 2.0 # How long the projectile exists before disappearing (in seconds)

func _ready():
	# This function is called once when the projectile is added to the scene.
	print("Projectile spawned at: ", global_position) # Debugging print
	
	# Connect the 'body_entered' signal.
	# This signal is emitted when another physics body enters this Area2D's collision shape.
	# We connect it to our custom function '_on_body_entered'.
	area_entered.connect(_on_area_entered)
	
	# Create a timer to automatically remove the projectile after its lifetime.
	# get_tree() refers to the current scene tree.
	# create_timer() creates a one-shot timer.
	var timer = get_tree().create_timer(lifetime)
	# Connect the 'timeout' signal of the timer to our custom 'on_timeout' function.
	timer.timeout.connect(on_timeout)

func _process(delta):
	# This function is called every frame. 'delta' is the time since the last frame.
	# Update the projectile's position based on its direction, speed, and delta.
	# We use 'position' directly for Area2D simple linear movement.
	position += direction * speed * delta

	# print("Projectile moving. Position: ", position) # Optional debugging print to see movement

# This is a custom function that the player script will call to set the projectile's direction.
# It takes a Vector2 argument called 'new_direction'.
func set_direction(new_direction: Vector2):
	# Normalize the direction vector to ensure its length is 1.
	# This makes sure the projectile always travels at 'speed' regardless of the input vector's magnitude.
	direction = new_direction.normalized()
	# print("Projectile direction set to: ", direction) # Debugging print

# This function is called automatically when the timer (created in _ready) runs out.
func on_timeout():
	# Safely remove the projectile node from the scene tree and free its memory.
	# This prevents an accumulation of projectiles and saves resources.
	queue_free()
	print("Projectile despawned!") # Debugging print when it's removed

func _on_area_entered(area: Area2D):
	print("Projectile entered area: ", area.name)
	print("  Area's class: ", area.get_class())
	print("  Area's collision layer: ", area.collision_layer)
	print("  Area's collision mask: ", area.collision_mask)
	# Debugging print
	# Check if the collided 'body' is an Enemy.
	# We can check its type using 'is' keyword or its name.
	# 'is CharacterBody2D' checks if it's a CharacterBody2D (which Enemy is).
	# You could also check 'if body.name == "Enemy"' but checking class is more robust.
	if area.is_in_group("enemies"):
		# Call the 'take_hit()' function on the collided enemy.
		# Ensure the 'Enemy.gd' script has a 'take_hit()' function.
		area.take_hit()
		print("Projectile hit an enemy!")
		queue_free()
		print("Projectile despawned by collision!")

	# After hitting anything (or specifically an enemy), the projectile should disappear.
	# This prevents the projectile from going through multiple enemies or walls.
 # Debugging print
