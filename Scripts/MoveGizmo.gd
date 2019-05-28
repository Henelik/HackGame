extends Area2D

# Declare member variables here.
var prev
var tileX
var tileY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Moving")
		prev.move(tileX, tileY)
