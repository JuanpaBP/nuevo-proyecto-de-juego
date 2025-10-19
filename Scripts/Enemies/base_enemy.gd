extends CharacterBody2D

class_name base_enemy

#Base enemy stats
var speed = 100 # Enemy movement speed (pixels per second)
var player_node: Node = null # Reference to the player node
var hp = 100

signal defeated

var is_chasing = true

# Variables for the bouncing of each other
@export var push_factor = 4000.0 # Magic number to calculate push force.
@export var max_push_speed = 50.0
@export var push_velocity = Vector2.ZERO

@onready var sprite = $Sprite
@onready var soft_collision_area = $Area2D

var sprite_right
var sprite_left

func _ready():
	player_node = get_node("/root/Game/Player")
	if player_node == null:
		print("ERROR: Player node 'Player' not found by enemy at path '/root/Game/Player'!")
		print("Please ensure your main scene's root is named 'Game' and your player node is named 'Player'.")

func _physics_process(delta: float) -> void:
	_apply_soft_collision()
	if player_node != null:
		var direction_to_player = (player_node.global_position - global_position).normalized()
		var final_velocity = direction_to_player * speed + push_velocity
		if final_velocity.length() > speed + max_push_speed:
			final_velocity = final_velocity.normalized() * (speed + max_push_speed)
		velocity = final_velocity
		move_and_slide()
		push_velocity = push_velocity.move_toward(Vector2.ZERO, delta * 1000)
		
		if direction_to_player.x > 0:
			sprite.texture = sprite_right
		elif direction_to_player.x < 0:
			sprite.texture = sprite_left

func take_hit(damage: int):
	hp = hp - damage
	if(hp <= 0):
		defeated.emit()
		_remove_from_scene() 

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

func apply_push(push_vector):
	push_velocity += push_vector

func _remove_from_scene():
	queue_free()
