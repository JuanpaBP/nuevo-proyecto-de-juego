extends Node2D

# The size of the viewport in pixels
var viewport_size = Vector2(1152, 648)
# The size of each cell in pixels
var cell_size = 64
# We use a color to visually represent the walls
var bgTile = preload("res://Scenes/Rooms/Woods_floor.tscn")
var wall = preload("res://Scenes/Rooms/Wall.tscn")
var rock = preload("res://Scenes/Rooms/Stone_obstacle.tscn")

var num_cells_x = int(viewport_size.x / cell_size)
var num_cells_y = int(viewport_size.y / cell_size)
var room_matrix = []
@export var gate_size = 3
@export var rock_chance = 0.1
var empty_cells_counter = 0
var room_available_positions = []


enum CellType{
	EMPTY,
	WALL, 
	ROCK,
	GATE_SPACE
}

func get_room_available_position():
	return room_available_positions

func _ready():
	# Loop through the grid and create a label for each cell
	room_matrix.resize(num_cells_x)
	for x in range(num_cells_x):
		room_matrix[x] = []
		room_matrix[x].resize(num_cells_y)

func generate_room_layout():
	#Loop through the grid
	for y in range(num_cells_y):
		for x in range(num_cells_x):
			var is_outer_wall = is_outer_wall(x, y)
			var is_gate_space = false
			
			#Check for gate positions
			#is_gate_space = get_gate_position(x, y)
			
			#Populate
			if is_outer_wall and not is_gate_space:
				room_matrix[x][y] = CellType.WALL
			elif is_gate_space:
				room_matrix[x][y] = CellType.GATE_SPACE
			else:
				var is_random_rock = randf() < rock_chance #Rock chance
				if is_random_rock:
					room_matrix[x][y] = CellType.ROCK
				else:
					room_matrix[x][y] = CellType.EMPTY
					empty_cells_counter += 1

func instantiate_room():
	for y in range(num_cells_y):
		for x in range(num_cells_x):
			var position = Vector2(x*cell_size, y*cell_size)
			var cell_type = room_matrix[x][y]
			
			#Instantiate the background tile for every cell first
			var background_instance = bgTile.instantiate();
			add_child(background_instance)
			background_instance.position = position
			
			if cell_type == CellType.WALL:
				var wall_instance = wall.instantiate()
				add_child(wall_instance)
				wall_instance.position = position
			elif cell_type == CellType.ROCK:
				var rock_instance = rock.instantiate()
				add_child(rock_instance)
				rock_instance.position = position
			elif cell_type == CellType.EMPTY:
				room_available_positions.push_back(position)


func is_outer_wall(x: int, y: int):
	return x == 0 or x == num_cells_x - 1 or y == 0 or y == num_cells_y - 1

#func get_gate_position(x: int, y: int):
	#var gate_y_center = int(num_cells_y / 2)
	#var gate_x_center = int(num_cells_x / 2)
	#if x == 0 and abs(y - gate_y_center) < gate_size / 2: #Left wall
		#return true
	#elif x == num_cells_x - 1 and abs(y - gate_y_center) < gate_size / 2: #Right wall
		#return true
	#elif y == 0 and abs(x - gate_x_center) < gate_size / 2: #Top Wall
		#return true
	#elif y == num_cells_y - 1 and abs(x - gate_x_center) < gate_size / 2: #Bottom Wall
		#return true
