extends KinematicBody2D

# Declare member variables here.
var speed = 350
var velocity = Vector2()
export(Array, int) var playerTypes # 0 is local, 1 is AI, 2 is online
var currentPlayer # an index of the array
var selectedProgram
var progs = []
var bMap

# Called when the node enters the scene tree for the first time.
func _ready():
	currentPlayer = -1
	bMap = get_node("../BattleMap")
	_populateProgArray()
	_nextTurn()

func _populateProgArray():
	var progList = get_tree().get_nodes_in_group("Programs")
	var tempProgs
	for i in range(playerTypes.size()):
		tempProgs = []
		for p in progList:
			if p.owningPlayerId == i:
				tempProgs.append(p)
		progs.append(tempProgs)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	velocity.y = int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up"))
	move_and_slide(velocity.normalized() * speed)

func _on_EndTurnButton_pressed():
	print("Ending turn...")
	_nextTurn()
	
func _nextTurn():
	# deselect the currently selected program
	if selectedProgram != null:
		selectedProgram._deselect()
		selectedProgram = null
	currentPlayer = (currentPlayer+1)%playerTypes.size()
	for p in progs[currentPlayer]:
		p.newTurn()
	print("It is now player " + str(currentPlayer) + "'s turn.")
	if playerTypes[currentPlayer] == 1:
		_AITurn()

func _AITurn():
	for p in progs[currentPlayer]:
		var targets = []
		for i in range(playerTypes.size()): # create the list of target tiles
			if i == currentPlayer: # don't add this player's programs to the targets
				continue
			for o in progs[i]:
				targets.append(Vector2(o.tileX, o.tileY)) # add the program heads
				for t in o.tailSectors:
					targets.append(Vector2(t.tileX, t.tileY)) # and tails
		bMap._updateMoveMap(p)
		p.movePath(bMap.findPathGroup(Vector2(p.tileX, p.tileY), targets, 1))
	_nextTurn()

func currentPlayerType():
	return playerTypes[currentPlayer]
	