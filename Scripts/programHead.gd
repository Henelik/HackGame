extends Area2D

# Declare member variables here.
export(NodePath) var levelRef
export(int) var tileX
export(int) var tileY
var moveGizmos = []

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
		var gizScene = load("res://Databattle/MoveGizmo.tscn")
		for i in [[tileX, tileY-1], [tileX, tileY+1], [tileX-1, tileY], [tileX+1, tileY]]:
			print("Testing " + str(i))
			if levelTiles.get_cell(i[0], i[1]) > 0:
				print("Adding tile")
				moveGizmos.append(gizScene.instance())
				moveGizmos[-1].position.x = (i[0]+1)*32
				moveGizmos[-1].position.y = -i[1]*32
				get_node("/root").add_child(moveGizmos[-1])
