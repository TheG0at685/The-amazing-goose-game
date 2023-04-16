extends Node2D


onready var level = load("res://levels/level scenes/Level1.tscn").instance()
var current_level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_level(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_level(level_number):
	level.queue_free()
	current_level = level_number
	level = load("res://levels/level scenes/Level"+str(level_number)+".tscn").instance()
	add_child(level)
