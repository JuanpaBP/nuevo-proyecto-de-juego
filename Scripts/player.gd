extends CharacterBody2D

var speed = 200 # Pixels per second
var current_direction = Vector2(1, 0) # Initial direction: Vector2(x, y) (1,0) means right
var last_direction = current_direction # used for shooting. #If current_direction is (0, 0) bullet doesnt fly 

#Projectile variables
var ProjectileScene = preload("res://Scenes/Projectile.tscn")
var can_shoot = true # A flag to control if the player can shoot right now
var shoot_cooldown_time = 0.3 # Time (in seconds) between shots
var shoot_timer = 0.0 # Internal timer to track cooldown progress

#Player Health and Damage Variables
var max_health = 100.0
var health = max_health # Current health, starts at max
var is_invulnerable = false # A flag for temporary invulnerability (not used yet, but good practice)

#Damage Var ---
var damage_per_tick = 5.0 # How much health is drained per tick
var damage_tick_rate = 0.2 # How often damage is applied (in seconds)
var damage_timer = 0.0 # Timer to track damage ticks
var overlapping_enemies = 0 # Counter for how many enemies are currently overlapping the player

var hitbox: Area2D = null

@onready var floatingHealthBar = $FloatingHealthBar #Again, we get the reference to a child node.
#Different from what we did for the projectile (although both are scenes) because the projectile is
#A separated scene, while the health bar is a child of the Player Node. 

@onready var player_sprite = $Sprite2D
var sprite_right = preload("res://Assets/Carly_right.png")
var sprite_left = preload("res://Assets/Carly_left.png")

signal died

func _ready():
	if current_direction == Vector2.ZERO:
		current_direction = Vector2(1, 0) # Default to shooting right if player isn't moving
	#Initialize the healthbar
	update_health(max_health)
	player_sprite.texture = sprite_right

func _physics_process(delta):
	_movement()
	shoot(delta)
	if overlapping_enemies > 0 and not is_invulnerable:
		damage_timer += delta
		print("Damage taken")
		if damage_timer > damage_tick_rate:
			take_damage(damage_per_tick * overlapping_enemies)
			damage_timer = 0
	if current_direction.x > 0:
		player_sprite.texture = sprite_right
	elif current_direction.x < 0:
		player_sprite.texture = sprite_left
	
func shoot(delta):
	if not can_shoot: # If currently on cooldown
		shoot_timer -= delta # Decrease the timer by the time since last frame
		if shoot_timer <= 0: # If timer has run out
			can_shoot = true # Allow shooting again
			
	if Input.is_action_just_pressed("ui_accept") and can_shoot:
		can_shoot = false # Start cooldown
		shoot_timer = shoot_cooldown_time # Reset the timer
		
		# 1. Instantiate the Projectile scene.
		# This creates a new independent copy of your Projectile.tscn node tree in memory.
		var projectile_instance = ProjectileScene.instantiate()
		
		# 2. Position the projectile.
		# We want it to appear slightly offset from the player's center in the current direction.
		# 'global_position' is the player's world position.
		# 'current_direction * offset' moves it away from the player.
		# Calculation for offset: half of player size (50/2 = 25) + half of projectile size (20/2 = 10) + a small gap (e.g., 5) = 40
		var spawn_offset = 40 # Adjust this value if projectiles spawn too close/far
					
		projectile_instance.global_position = global_position + last_direction * spawn_offset
		
		# 3. Set the projectile's direction.
		# We call the 'set_direction' function that we created in Projectile.gd.
		projectile_instance.set_direction(last_direction)
		
		# 4. Add the projectile instance to the active scene tree.
		# IMPORTANT: We add it as a child of the 'Game' node (the player's parent),
		# NOT as a child of the player. If it were a child of the player, it would move with the player!
		get_parent().add_child(projectile_instance)
		print("Shot fired! Projectile spawned.") #Debugging confirmation

func get_input():
	# Input.get_vector returns a vector2 value created by passing the four Input actions 
	# for the positive and negative X and Y axes (defined in the Input Map).
	# (already manages Vector calculations that allows user avoid a typical bug where
	# a character moves faster diagonally than in straight lines because of failed mathzzz)
	current_direction = Input.get_vector("left", "right", "up", "down")
	if not Vector2.ZERO.is_equal_approx(current_direction):
			last_direction = current_direction
	velocity = current_direction * speed

func _movement():
	get_input()
	# Move the character and slide along collisions
	move_and_slide()

func take_damage(amount):
	health -= amount
	print("Player took ", amount, " damage! Current health: ", health)
	# Check for death condition
	update_health(health)
	if health <= 0:
		print("Player has died!")
		# For now, let's just remove the player from the scene
		died.emit()
		queue_free()


func update_health(current: float):
	if floatingHealthBar:
		floatingHealthBar.update_health(current, max_health)
	else:
		print("ERROR: The healthbar is not found")

#These 2 functions should be "connected" to the signal that the area emits
#And this can be done in the ready function, but it can also be done visually using Godot nodes and signals.

func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		overlapping_enemies += 1
		print("Enemy entered player area. Overlapping enemies: ", overlapping_enemies)


func _on_hitbox_body_exited(body: Node2D):
	if body.is_in_group("enemies"):
		overlapping_enemies -= 1
		print("Enemy exited player area. Overlapping enemies: ", overlapping_enemies)
