extends Node2D

var EnemyScene = preload("res://Scenes/Enemy.tscn")

# This is a reference to the player node in the scene
@onready var player_node = $Player
@onready var enemy_spawner = $EnemySpawner
@onready var room_generator = $RoomGenerator

@onready var message_label = $CanvasLayer/MessageLabel
@onready var restart_button = $CanvasLayer/RestartButton


@export var enemy_count = 4

var enemy_list = []

func _ready():
	print("Game _ready() called.")
	
	# Connect the player's died signal to our game over function.
	player_node.died.connect(_on_player_died)
	
	#Set up initial scene
	message_label.hide()
	restart_button.hide()
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	#Draw the randomized room
	room_generator.generate_room_layout();
	room_generator.instantiate_room();
	
	
	#Initial enemy spawn.
	enemy_spawner.num_enemies_to_spawn = enemy_count
	enemy_spawner.all_enemies_defeated.connect(_on_victory_trigger)
	enemy_list = enemy_spawner.spawn_enemies()
	print(enemy_list)
	
	for enemy in enemy_list:
		enemy_spawner.position_enemies(enemy, room_generator.get_room_available_position())
	
	print("Initial enemy count: ", enemy_count)
	

func _on_victory_trigger():
	print("All enemies defeated! Room cleared.")
	message_label.text = "Room Cleared!"
	message_label.show()
	# We will add logic here to start loading next rooms or whatever
	# For now, just a restart button to play again
	restart_button.show()
	get_tree().paused = true
	

func _on_player_died():
	message_label.text = "Game Over!"
	message_label.show()
	restart_button.show()
	get_tree().paused = true
	

func _on_restart_button_pressed():
	print("Restart game...")
	get_tree().paused = false
	# Reload the current scene to restart the game
	enemy_spawner.clean_enemies_from_scene()
	get_tree().reload_current_scene()
