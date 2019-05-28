extends Area2D

# Declare member variables here.
export(NodePath) var levelRef
export(int) var movesPerTurn
export(int) var maxSize
export(String) var progName
export(Color) var col

var tileX
var tileY
var moveGizmos = []
var movesRemaining
var selected
var tailSectors = []
var tailScn = load("res://Databattle/TailSector.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	movesRemaining = movesPerTurn
	tileX = round(position.x/32)
	tileY = round(position.y/32)
	position.x = tileX*32
	position.y = tileY*32
	selected = false
	$Sprite.modulate = col

func _select():
	if selected == true:
		return
	selected = true
	print("Selecting " + progName)
	if movesRemaining > 0:
		var levelTiles = get_node(levelRef)
		var gizScn = load("res://Databattle/MoveGizmo.tscn")
		var dList = [[tileX+1, tileY], [tileX, tileY-1], [tileX-1, tileY], [tileX, tileY+1]]
		for i in range(4):
			if levelTiles.get_cell(dList[i][0]-1, dList[i][1]-1) > 0:
				moveGizmos.append(gizScn.instance())
				moveGizmos[-1].position.x = dList[i][0]*32
				moveGizmos[-1].position.y = dList[i][1]*32
				moveGizmos[-1].tileX = dList[i][0]
				moveGizmos[-1].tileY = dList[i][1]
				moveGizmos[-1].prev = self
				get_node("/root").add_child(moveGizmos[-1])

func _deselect():
	if selected == false:
		return
	selected = false
	for g in moveGizmos:
		g.queue_free()
	moveGizmos = []
	
func _addTile(x, y):
	tailSectors.push_front(tailScn.instance())
	get_node("/root").add_child(tailSectors[0])
	tailSectors[0].setColor(col)
	tailSectors[0].position.x = x*32
	tailSectors[0].position.y = y*32
	while tailSectors.size() > maxSize:
		tailSectors[-1].queue_free()
		tailSectors.pop_back()

func move(x, y):
	_addTile(tileX, tileY)
	tileX = x
	tileY = y
	position.x = tileX*32
	position.y = tileY*32
	movesRemaining -= 1
	_deselect()
	_select()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Clicked " + progName)
		_select()
