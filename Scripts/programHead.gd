extends Area2D

# Declare member variables here.
export(int) var movesPerTurn = 2
export(int) var apPerTurn = 1
export(int) var maxSize = 3
export(String) var progName
export(Color) var col
export(int) var owningPlayerId
export(Array, String, FILE, "*.tscn") var abilityRefs
export(String, FILE, "*.png") var iconPath

var levelRef = "../BattleMap"
var tileX
var tileY
var moveGizmos = []
var movesLeft
var apLeft
var selected
var tailSectors = []
var tailScn = load("res://Databattle/TailSector.tscn")
var abilities = []
var turnEnded = false # true if this program has ended its turn
onready var cam = get_node("/root/Battle/CamControl")

# Called when the node enters the scene tree for the first time.
func _ready():
	tileX = round(position.x/32)
	tileY = round(position.y/32)
	position.x = tileX*32
	position.y = tileY*32
	selected = false
	$SectorSprite.modulate = col
	for a in abilityRefs: # load and instantiate the ability nodes from the references
		abilities.append(load(a).instance())
		add_child(abilities[-1])
		abilities[-1].tileX = tileX
		abilities[-1].tileY = tileY
	if iconPath != "":
		$IconSprite.texture = load(iconPath)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		print("Clicked " + progName)
		cam.selectProgram(self)

func _select():
	print("Selecting " + progName)
	_showMoveGizmos()

func _deselect():
	_hideMoveGizmos()

func _passiveSelect(): # the current player doesn't control this program
	print("Passive selecting " + progName)
	
func _showMoveGizmos():
	get_node(levelRef)._updateMoveMap(self)
	if movesLeft > 0:
		var gizScn = load("res://Databattle/Gizmo.tscn")
		for x in range(tileX-movesLeft, tileX+movesLeft+1):
			for y in range(tileY-movesLeft, tileY+movesLeft+1):
				if abs(x-tileX)+abs(y-tileY) <= movesLeft and not (x == tileX and y == tileY):
					var path = get_node(levelRef).findPathGroup(Vector2(tileX, tileY), [Vector2(x, y)])
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
	get_node("moveSoundPlayer").play()
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

func gizmoCallback(x, y):
	_hideMoveGizmos()
	if cam.currentPlayerType() == 0:
		yield(multiMove(x, y), "completed")
	if movesLeft > 0:
		_showMoveGizmos()
	
func multiMove(x, y):
	var path = get_node(levelRef).findPathGroup(Vector2(tileX, tileY), [Vector2(x, y)])
	if path != null:
		for p in path:
			if movesLeft <= 0:
				return
			yield(get_tree().create_timer(.25),"timeout")
			move(p.x, p.y)

func movePath(path):
	if path != null:
		for p in path:
			if movesLeft <= 0:
				return
			yield(get_tree().create_timer(.25),"timeout")
			move(p.x, p.y)
	
func newTurn(): # reset moves and ap
	movesLeft = movesPerTurn
	apLeft = apPerTurn
	turnEnded = false

func damage(amount):
	for i in range(amount):
		if tailSectors.size() == 0:
			_die()
			return
		tailSectors[-1].queue_free()
		tailSectors.pop_back()

func _die():
	if cam.selectedProgram == self:
		cam.deselectProgram()
	cam.progs[owningPlayerId].erase(self)
	queue_free()
