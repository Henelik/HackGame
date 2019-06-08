extends Area2D

# Declare member variables here.
export(int) var movesPerTurn = 2
export(int) var apPerTurn = 1
export(int) var maxSize = 3
export(String) var progName
export(Color) var col
export(int) var owningPlayerId
export(Array, String, FILE, "*.tscn") var abilityRefs
export(String) var flavorText

var tileX : int
var tileY : int
var moveGizmos : Array = []
var movesLeft : int
var apLeft : int
var tailSectors : Array = []
var tailScn = load("res://Databattle/TailSector.tscn")
var connectors : Array = []
var horizScn = load("res://Databattle/HorizontalConnector.tscn")
var vertScn = load("res://Databattle/VerticalConnector.tscn")
var abilities : Array = []
var turnEnded = false # true if this program has ended its turn
onready var cam = get_node("../BattleCam")
onready var level = get_node("../BattleMap")

# Called when the node enters the scene tree for the first time.
func _ready():
	tileX = round(position.x/32)
	tileY = round(position.y/32)
	position.x = tileX*32
	position.y = tileY*32
	$SectorSprite.modulate = col
	for a in abilityRefs: # load and instantiate the ability nodes from the references
		abilities.append(load(a).instance())
		add_child(abilities[-1])
		abilities[-1].tileX = tileX
		abilities[-1].tileY = tileY
		abilities[-1].camRef = cam

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Clicked " + progName)
		cam.selectProgram(self)

func _select():
	print("Selecting " + progName)
	get_node("SelectSoundPlayer").play()
	_showMoveGizmos()
	_showConnectors()

func _deselect():
	_hideMoveGizmos()

func _passiveSelect(): # the current player doesn't control this program
	print("Passive selecting " + progName)
	
func _showMoveGizmos():
	level._updateMoveMap(self)
	if movesLeft > 0:
		var gizScn = load("res://Databattle/Gizmo.tscn")
		for x in range(tileX-movesLeft, tileX+movesLeft+1):
			for y in range(tileY-movesLeft, tileY+movesLeft+1):
				if abs(x-tileX)+abs(y-tileY) <= movesLeft and not (x == tileX and y == tileY):
					var path = level.findPathGroup(Vector2(tileX, tileY), [Vector2(x, y)])
					if path != null and path.size() <= movesLeft:
						moveGizmos.append(gizScn.instance())
						moveGizmos[-1].position.x = x*32
						moveGizmos[-1].position.y = y*32
						moveGizmos[-1].tileX = x
						moveGizmos[-1].tileY = y
						moveGizmos[-1].owningNode = self
						get_node("/root").add_child(moveGizmos[-1])

func _hideMoveGizmos():
	print("hiding gizmos")
	for g in moveGizmos:
		g.queue_free()
		get_node("/root").remove_child(g)
	moveGizmos = []

func _addTailSector(x : int, y : int):
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
	while tailSectors.size() > maxSize-1:
		tailSectors[-1].queue_free()
		tailSectors.pop_back()

func move(x : int, y : int):
	print("Moving " + progName + " to " + str([x, y]))
	get_node("MoveSoundPlayer").play()
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
	if movesLeft == 0 and abilities.size() == 0:
		turnEnded = true
	# update ability positions
	for a in abilities:
		a.tileX = tileX
		a.tileY = tileY
	_showConnectors()

func gizmoCallback(x : int, y : int):
	_hideMoveGizmos()
	if cam.currentPlayerType() == 0:
		yield(multiMove(x, y), "completed")
	if movesLeft > 0:
		_showMoveGizmos()
	
func multiMove(x, y):
	cam.programMoving = true
	var path = level.findPathGroup(Vector2(tileX, tileY), [Vector2(x, y)])
	if path != null:
		for p in path:
			if movesLeft <= 0:
				break
			yield(get_tree().create_timer(.25),"timeout")
			move(p.x, p.y)
	_showConnectors()
	cam.programMoving = false
	return

func movePath(path):
	cam.programMoving = true
	if path != null:
		for p in path:
			if movesLeft <= 0:
				break
			yield(get_tree().create_timer(.25),"timeout")
			move(p.x, p.y)
	cam.programMoving = false
	return
	
func newTurn(): # reset moves and ap
	movesLeft = movesPerTurn
	apLeft = apPerTurn
	turnEnded = false

func damage(amount : int):
	for i in range(amount):
		yield(get_tree().create_timer(.1),"timeout")
		if tailSectors.size() == 0:
			_die()
			return
		#tailSectors[-1].queue_free()
		tailSectors.pop_back().die()
		if not connectors.empty():
			connectors.pop_back().die()
	_showConnectors()
	return

func _die():
	if cam.selectedProgram == self:
		cam.deselectProgram()
	cam.progs[owningPlayerId].erase(self)
	# Add a temporary sector so that the death animation can be played
	var tempSector = tailScn.instance()
	tempSector.tileX = tileX
	tempSector.tileY = tileY
	tempSector.position.x = tileX*32
	tempSector.position.y = tileY*32
	get_node("/root").add_child(tempSector)
	tempSector.die()
	# play the sound
	get_node("DeathSoundPlayer").play()
	clear()
	queue_free()
	cam.checkWinner()
	
func clear():
	for t in self.tailSectors:
		t.queue_free()
	_hideConnectors()

func _showConnectors():
	_hideConnectors()
	for t in tailSectors:
		if (t.tileX == tileX+1 or t.tileX == tileX-1) and t.tileY == tileY:
			connectors.append(horizScn.instance())
			connectors[-1].setColor(col)
			connectors[-1].position.x = (t.position.x+position.x)/2
			connectors[-1].position.y = position.y
			get_node("/root").add_child(connectors[-1])
		if (t.tileY == tileY+1 or t.tileY == tileY-1) and t.tileX == tileX:
			connectors.append(vertScn.instance())
			connectors[-1].setColor(col)
			connectors[-1].position.x = t.position.x
			connectors[-1].position.y = (t.position.y+position.y)/2
			get_node("/root").add_child(connectors[-1])
	for i in range(tailSectors.size()-1):
		var t = tailSectors[i]
		for j in range(i, tailSectors.size()):
			var o = tailSectors[j]
			if (o.tileX == t.tileX+1 or o.tileX == t.tileX-1) and o.tileY == t.tileY:
				connectors.append(horizScn.instance())
				connectors[-1].setColor(col)
				connectors[-1].position.x = (o.position.x+t.position.x)/2
				connectors[-1].position.y = t.position.y
				get_node("/root").add_child(connectors[-1])
			if (o.tileY == t.tileY+1 or o.tileY == t.tileY-1) and o.tileX == t.tileX:
				connectors.append(vertScn.instance())
				connectors[-1].setColor(col)
				connectors[-1].position.x = t.position.x
				connectors[-1].position.y = (o.position.y+t.position.y)/2
				get_node("/root").add_child(connectors[-1])

func _hideConnectors():
	for c in connectors:
		c.queue_free()
	connectors = []
