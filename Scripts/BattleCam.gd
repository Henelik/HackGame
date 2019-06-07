extends KinematicBody2D

# Declare member variables here.
var speed = 350
var velocity = Vector2()
export(Array, int) var playerTypes # 0 is local, 1 is AI, 2 is online
export(Array, String) var playerNames
var currentPlayer # an index of the array
var selectedProgram
var selectedAbility
var progs = []
var bMap
var programMoving = false
var battleOver = false
var winningPlayer : int

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
	if battleOver:
		return
	get_node("Camera2D/EndTurnButton").visible = true
	deselectProgram()
	currentPlayer = (currentPlayer+1)%playerTypes.size() # increment the player
	if progs[currentPlayer].empty(): # if this player has no programs left
		return _nextTurn() # skip their turn
	for p in progs[currentPlayer]: # tell all this player's programs that it's their turn
		p.newTurn()
	print("It is now player " + str(currentPlayer) + "'s turn.")
	if playerTypes[currentPlayer] == 1: # play as the AI
		get_node("Camera2D/EndTurnButton").visible = false
		yield(get_tree().create_timer(.5),"timeout")
		_AITurn()
		
func selectProgram(prog):
	if selectedProgram == prog:
		deselectProgram()
		return
	if selectedProgram != null:
		deselectProgram()
	if selectedAbility != null:
		# don't select the program if we're trying to attack it
		#if selectedAbility.targetType == "enemy" and prog.owningPlayerId != currentPlayer:
		return
	selectedProgram = prog
	get_node("Camera2D/ActionButtons").visible = true
	# add abilities to actionButtons
	for a in range(prog.abilities.size()):
		if a < 4:
			get_node("Camera2D/ActionButtons/ActionButton" + str(a+1)).text = prog.abilities[a].abilityName
	if selectedProgram in progs[currentPlayer] and playerTypes[currentPlayer] == 0 and not prog.turnEnded:
		prog._select()
	else:
		prog._passiveSelect()
	
func deselectProgram():
	if selectedProgram != null:
		if weakref(selectedProgram).get_ref():
			selectedProgram._deselect()
		deselectAbility()
		selectedProgram = null
		get_node("Camera2D/ActionButtons").visible = false
		get_node("Camera2D/ActionButtons/ActionButton1").text = ""
		get_node("Camera2D/ActionButtons/ActionButton2").text = ""
		get_node("Camera2D/ActionButtons/ActionButton3").text = ""
		get_node("Camera2D/ActionButtons/ActionButton4").text = ""

func _AITurn():
	for p in progs[currentPlayer]:
		var abRange = 1
		print(p.progName)
		if not p.abilities.empty():
			if p.abilities[0].maxRange > abRange:
				abRange = p.abilities[0].maxRange
		var targets = []
		for i in range(playerTypes.size()): # create the list of target tiles
			if i == currentPlayer: # don't add this player's programs to the targets
				continue
			for o in progs[i]:
				targets.append(Vector2(o.tileX, o.tileY)) # add the program heads
				for t in o.tailSectors:
					targets.append(Vector2(t.tileX, t.tileY)) # and tails
		bMap._updateMoveMap(p)
		var path = bMap.findPathGroup(Vector2(p.tileX, p.tileY), targets, 1)
		if path != null:
			yield(p.movePath(path), "completed")
		if not p.abilities.empty():
			yield(get_tree().create_timer(.25),"timeout")
			var t = bMap.findInRange(Vector2(p.tileX, p.tileY), targets, p.abilities[0].maxRange)
			if t != null:
				p.abilities[0].gizmoCallback(t.x, t.y)
	yield(get_tree().create_timer(.5),"timeout")
	_nextTurn()

func checkWinner():
	var eliminatedPlayers : Array = []
	var winner : int
	for p in range(progs.size()):
		if progs[p].empty():
			eliminatedPlayers.append(1) # this player has been eliminated
		else:
			eliminatedPlayers.append(0) # this player has not been eliminated
	if eliminatedPlayers.count(0) == 1:
		endGame(eliminatedPlayers.find(0))

func endGame(winner : int):
	get_node("Camera2D/EndTurnButton").visible = false
	get_node("Camera2D/ActionButtons").visible = false
	print("Battle ended")
	battleOver = true
	winningPlayer = winner
	get_node("Camera2D/EndScreen").visible = true

func exitBattle():
	for pl in progs:
		for p in pl:
			p.clear()
	get_node("/root/GameRoot").battleCallback(winningPlayer, true)

func currentPlayerType():
	return playerTypes[currentPlayer]

func _on_ActionButton1_pressed():
	deselectAbility()
	selectAbility(0)

func _on_ActionButton2_pressed():
	deselectAbility()
	selectAbility(1)

func _on_ActionButton3_pressed():
	deselectAbility()
	selectAbility(2)

func _on_ActionButton4_pressed():
	deselectAbility()
	selectAbility(3)
	
func selectAbility(n):
	if selectedProgram != null:
		if selectedProgram.abilities.size() > n and not selectedProgram.turnEnded:
			if selectedProgram.owningPlayerId == currentPlayer and playerTypes[currentPlayer] == 0:
				selectedProgram.abilities[n]._select()
				selectedAbility = selectedProgram.abilities[n]
				selectedProgram._hideMoveGizmos()

func deselectAbility():
	if selectedAbility != null:
		selectedAbility._deselect()
		selectedAbility = null

func _on_ExitButton_pressed():
	exitBattle()
