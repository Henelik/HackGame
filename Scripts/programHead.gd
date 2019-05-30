extends Area2D

# Declare member variables here.
export(NodePath) var levelRef
export(int) var movesPerTurn
export(int) var apPerTurn
export(int) var maxSize
export(String) var progName
export(Color) var col
export(int) var owningPlayerId

var tileX
var tileY
var moveGizmos = []
var movesLeft
var apLeft
var selected
var tailSectors = []
var tailScn = load("res://Databattle/TailSector.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	tileX = round(position.x/32)
	tileY = round(position.y/32)
	position.x = tileX*32
	position.y = tileY*32
	selected = false
	$Sprite.modulate = col
	newTurn()

func _select():
	var cam = get_node("../CamControl")
	if cam.selectedProgram != null:
		cam.selectedProgram._deselect()
	cam.selectedProgram = self
	print("Selecting " + progName)
	get_node(levelRef)._updateMoveMap(self)
	if movesLeft > 0:
		var gizScn = load("res://Databattle/Gizmo.tscn")
		for x in range(tileX-movesLeft, tileX+movesLeft+1):
			for y in range(tileY-movesLeft, tileY+movesLeft+1):
				if abs(x-tileX)+abs(y-tileY) <= movesLeft and not (x == tileX and y == tileY):
					var path = get_node(levelRef).findPath(Vector2(tileX, tileY), Vector2(x, y))
					if path != null and path.size() <= movesLeft:
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

func _passiveSelect(): # the current player doesn't control this program
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
			t.queue_free()
			tailSectors.erase(t)
	_addTailSector(tileX, tileY)
	tileX = x
	tileY = y
	position.x = tileX*32
	position.y = tileY*32
	movesLeft -= 1

func gizmoCallback(x, y):
	if get_node("../CamControl").currentPlayerType() == 0:
		multiMove(x, y)
	
func multiMove(x, y):
	var path = get_node(levelRef).findPath(Vector2(tileX, tileY), Vector2(x, y))
	for p in path:
		move(p.x, p.y)
	_deselect()
	_select()
	
func movePath(path):
	for p in path:
		if movesLeft <= 0:
			return
		move(p.x, p.y)
	
func newTurn(): # reset moves and ap
	movesLeft = movesPerTurn
	apLeft = apPerTurn

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
