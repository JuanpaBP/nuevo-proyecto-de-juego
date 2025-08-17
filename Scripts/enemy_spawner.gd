extends Node2D

#The naming conventions in godot are weird, scene variables start with caps
#and follow camelCase as a separator, but normal variables use _ to separate words
var EnemyScene = preload("res://Scenes/Enemy.tscn")

@export var num_enemies_to_spawn = 2
@export var spawn_radius = 300

var defeated_count = 0
signal all_enemies_defeated

#This function is always the same, and its always called when the node enters
#the scene tree(ie: the game starts and there's a node that preloads this scene
#then there the _ready function is called
func _ready():
	print("Spawner ready to be called")

func spawn_enemies():
	print("Spawning ", num_enemies_to_spawn, " enemies")
	defeated_count = 0
	
	for i in range(num_enemies_to_spawn):
		#Create a new instance of the enemy, and place it in the world.
		var enemy_instance = EnemyScene.instantiate();

		#Add a random offset within the defined spawn_radius.
		#randf_range(min, max) returns a random float between both parameters
		var random_offset = Vector2(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)
		
		enemy_instance.defeated.connect(_on_enemy_defeated)
		
		# With this, set the enemy world position
		#It has to be positioned bearing in mind the spawner's global position
		enemy_instance.global_position = global_position + random_offset
		
		#This sounds weird, but it will put the enemies, as children of 
		#the game scene, instead of the spawner.
		get_tree().get_root().add_child.call_deferred(enemy_instance)
		
		print("Spawned enemy ", i + 1, " at ", enemy_instance.global_position)
	print("All enemies spawned for this room")

func _on_enemy_defeated():
	defeated_count += 1
	print ("Enemy defeated! Total defeated: ", defeated_count)
	if defeated_count >= num_enemies_to_spawn:
		print("All enemies defeated!")
		all_enemies_defeated.emit()
		
func clean_enemies_from_scene():
	get_tree().call_group("enemies","_remove_from_scene")
