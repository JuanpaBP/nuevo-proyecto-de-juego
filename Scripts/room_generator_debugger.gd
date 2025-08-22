extends Node2D

# The size of the viewport in pixels
var viewport_size = Vector2(1152, 648)
# The size of each cell in pixels
var cell_size = 64
# We use a color to visually represent the walls
var bgTile = preload("res://Scenes/WoodsFloor.tscn")
var wall = preload("res://Scenes/wall.tscn")
var rock = preload("res://Scenes/Stone_obstacle.tscn")

var num_cells_x = int(viewport_size.x / cell_size)
var num_cells_y = int(viewport_size.y / cell_size)
var room_matrix = []


func _ready():
	# Loop through the grid and create a label for each cell
	var counter = 0
	var bgt = bgTile.instantiate();
	for y in range(num_cells_y):
		for x in range(num_cells_x):
			var label = Label.new()
			var background = Texture2D.new()
			# Set the text to the cell's coordinates for easy visualization
			label.text = str(counter)
			
			# --- CORRECTION: Set the label's alignment to top-left. ---
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			
			# --- CORRECTION: Position the label at the top-left corner of the cell. ---
			label.position = Vector2(x * cell_size, y * cell_size)
			var position = Vector2(x * cell_size, y * cell_size)

			var background_instance = bgTile.instantiate()
			add_child(background_instance)
			background_instance.position = position
			
			var is_outer_wall = x == 0 or x == num_cells_x - 1 or y == 0 or y == num_cells_y - 1
			
			# Logic to check if a cell is an outer wall
			if is_outer_wall:
				var tree_instance = wall.instantiate()
				add_child(tree_instance)
				tree_instance.position = position
			else:
				var is_random_rock = randf() < 0.1
				if is_random_rock:
					var rock_instance = rock.instantiate()
					add_child(rock_instance)
					rock_instance.position = position
				else:
					room_matrix.push_back(position)
			add_child(label)
			counter += 1

func position_enemies(body: CharacterBody2D):
	print("Positioning enemies in the grid...")
	var amount_of_empty_spaces = room_matrix.size()
	print("Amount of empty spaces: ", amount_of_empty_spaces)
	var random_position_selected = int(randf_range(0, amount_of_empty_spaces))
	print("Position selected for the first enemy...", random_position_selected)
	body.position = room_matrix.get(random_position_selected)
	
