extends Node2D

export(String) var abilityName = ""
export(String, "enemy", "friend", "self", "level") var targetType # used for UI and AI
export(int) var apCost = 1 # number of ability points this consumes
export(int) var maxRange = 1
export(Color) var gizmoColor
export(String) var description
var tileX : int
var tileY : int
var owningProgram
var targetProgram
var gizmos : Array = []
var camRef

func _ready():
	pass
	
func checkRange(target: Vector2):
	if abs(target.x-tileX)+abs(target.y-tileY) <= maxRange and not (target.x == tileX and target.y == tileY):
		return true
	return false

func _select():
	print("Selecting " + abilityName + " ability")
	_showGizmos()

func _deselect():
	print("Deselecting " + abilityName + " ability")
	_hideGizmos()
	
func _showGizmos():
	var gizScn = load("res://Databattle/Gizmo.tscn")
	for x in range(tileX-maxRange, tileX+maxRange+1):
		for y in range(tileY-maxRange, tileY+maxRange+1):
			if checkRange(Vector2(x, y)):
				gizmos.append(gizScn.instance())
				gizmos[-1].position.x = x*32
				gizmos[-1].position.y = y*32
				gizmos[-1].tileX = x
				gizmos[-1].tileY = y
				gizmos[-1].owningNode = self
				gizmos[-1].setColor(gizmoColor)
				get_tree().get_root().add_child(gizmos[-1])
	
func _hideGizmos():
	for g in gizmos:
		g.queue_free()
	gizmos = []
	
func _postFire():
	get_parent().turnEnded = true
	camRef.deselectProgram()

func findTarget(tile: Vector2):
	for player in camRef.progs:
		for p in player:
			if Vector2(p.tileX, p.tileY) == tile:
				fireProgram(p)
				return
			for t in p.tailSectors:
				if Vector2(t.tileX, t.tileY) == tile:
					fireProgram(p)
					return
	fireTile(tile) # no program occupies the targeted tile

func fireProgram(target):
	pass
	
func fireTile(tile: Vector2):
	pass

func gizmoCallback(x, y):
	if checkRange(Vector2(x, y)):
		findTarget(Vector2(x, y))
	else:
		print("Target is out of range for " + abilityName)