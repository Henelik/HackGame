extends KinematicBody2D

# Declare member variables here.
var speed = 350
var velocity = Vector2()
export(Array, int) var playerTypes # 0 is local, 1 is AI, 2 is online
var currentPlayer # an index of the array
var selectedProgram
var progs = []

# Called when the node enters the scene tree for the first time.
func _ready():
	currentPlayer = 0
	_populateProgArray()

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
		var shortestPath = null
		get_node("../BattleMap")._updateMoveMap(p)
		for o in progs[0]:
			if shortestPath == null:
				shortestPath = get_node("../BattleMap").findPath(Vector2(p.tileX, p.tileY), Vector2(o.tileX, o.tileY), 1)
			var temp = get_node("../BattleMap").findPath(Vector2(p.tileX, p.tileY), Vector2(o.tileX, o.tileY), 1)
			if temp == null:
				continue
			if temp.size() < shortestPath.size():
				shortestPath = temp
		if shortestPath == null:
			print("no path found")
			continue
		p.movePath(shortestPath)
	_nextTurn()

func currentPlayerType():
	return playerTypes[currentPlayer]
	