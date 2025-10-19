@icon("res://Assets/icons/invader.svg")
class_name Enemy

extends base_enemy

func _ready():
	super()
	load_sprite()

func load_sprite():
	sprite_right = preload("res://Assets/Rober_right.png")
	sprite_left = preload("res://Assets/Rober_left.png")
