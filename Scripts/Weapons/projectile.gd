extends Area2D

class_name projectile


# Variables for the projectile's behavior
var speed = 400.0 # How fast the projectile moves (pixels per second)
var direction = Vector2(0, 0) # This will be set by the player when it shoots, starts as (0,0)
var lifetime = 2.0 # How long the projectile exists before disappearing (in seconds)
@export var projectile_dmg = 0

func _ready():
	print("Projectile spawned at: ", global_position) # Debugging print
	
	body_entered.connect(_on_body_entered)
	
	var timer = get_tree().create_timer(lifetime)
	# Connect the 'timeout' signal of the timer to our custom 'on_timeout' function.
	timer.timeout.connect(on_timeout)

func _process(delta):
	position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

func on_timeout():
	queue_free()
	print("Projectile despawned!") # Debugging print when it's removed


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		body.take_hit(projectile_dmg)
		print("Projectile hit an enemy!")
		queue_free()
		print("Projectile despawned by collision!")
	elif body is StaticBody2D:
		print("Collided with a wall, despawning")
		queue_free()
		print("Despawned")
