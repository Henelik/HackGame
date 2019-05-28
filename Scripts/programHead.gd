extends Area2D

# Declare member variables here.
export(NodePath) var levelRef
export(int) var tileX
export(int) var tileY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _select():
	pass
	
func _move(target):
	pass
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Clicked")
		var levelTiles = get_node(levelRef)
		print(levelTiles.get_cell(tileX, tileY-2))
