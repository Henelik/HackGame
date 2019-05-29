extends Area2D

# Declare member variables here.
export(NodePath) var levelRef
export(int) var movesPerTurn
export(int) var maxSize
export(String) var progName
export(Color) var col
export(int) var owningPlayerId

var tileX
var tileY
var moveGizmos = []
var movesRemaining
var selected
var tailSectors = []
var tailScn = load("res://Databattle/TailSector.tscn")
var pf = AStar.new()

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
	var cam = get_node("../CamControl")
	if cam.selectedProgram != null:
		cam.selectedProgram._deselect()
	cam.selectedProgram = self
	print("Selecting " + progName)
	if movesRemaining > 0:
		var levelTiles = get_node(levelRef)
		var gizScn = load("res://Databattle/Gizmo.tscn")
		for x in range(tileX-movesRemaining, tileX+movesRemaining+1):
			for y in range(tileY-movesRemaining, tileY+movesRemaining+1):
				if levelTiles.get_cell(x-1, y-1) > 0 and abs(x-tileX)+abs(y-tileY) <= movesRemaining and not (x == tileX and y == tileY):
					moveGizmos.append(gizScn.instance())
					moveGizmos[-1].position.x = x*32
					moveGizmos[-1].position.y = y*32
					moveGizmos[-1].tileX = x
					moveGizmos[-1].tileY = y
					moveGizmos[-1].owningNode = self
					get_node("/root").add_child(moveGizmos[-1])

func _deselect():
	get_node("../CamControl").selectedProgram = null
	for g in moveGizmos:
		g.queue_free()
	moveGizmos = []

func _passiveSelect(): # the current player can't order this program
	pass

func _addTailSector(x, y):
	for t in tailSectors: # If there is already a tail sector here
		if x == t.tileX and y == t.tileY:
			# Move the sector to the front of the list
			tailSectors.push_front(tailSectors.pop_back())
			return
	tailSectors.push_front(tailScn.instance())
	get_node("/root").add_child(tailSectors[0])
	tailSectors[0].setColor(col)
	tailSectors[0].tileX = x
	tailSectors[0].tileY = y
	tailSectors[0].position.x = x*32
	tailSectors[0].position.y = y*32
	while tailSectors.size() > maxSize:
		tailSectors[-1].queue_free()
		tailSectors.pop_back()

func move(x, y):
	print("Moving " + progName + " to " + str([x, y]))
	for t in tailSectors:
		if x == t.tileX and y == t.tileY:
			tailSectors.erase(t)
	_addTailSector(tileX, tileY)
	tileX = x
	tileY = y
	position.x = tileX*32
	position.y = tileY*32
	movesRemaining -= 1

func gizmoCallback(x, y):
	multiMove(x, y)
	
func multiMove(x, y):
	if x > tileX:
		for i in range(tileX+1, x+1):
			move(i, tileY)
	else:
		for i in range(tileX-1, x-1, -1):
			move(i, tileY)
	if y > tileY:
		for j in range(tileY+1, y+1):
			move(tileX, j)
	else:
		for j in range(tileY-1, y-1, -1):
			move(tileX, j)
	_deselect()
	_select()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Clicked " + progName)
		var cam = get_node("../CamControl")
		if cam.currentPlayer != owningPlayerId or cam.playerTypes[owningPlayerId] != 0:
			_passiveSelect()
		elif cam.selectedProgram == self:
			_deselect()
		else:
			_select()

func damage(amount):
	for i in range(amount):
		if tailSectors.size() == 0:
			_die()
			return
		tailSectors[-1].queue_free()
		tailSectors.pop_back()

func _die():
	queue_free()
