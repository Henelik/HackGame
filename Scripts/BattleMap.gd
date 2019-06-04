extends TileMap

var moveMap # dictionary of the cost to move to each valid tile

func _ready():
	pass

func _updateMoveMap(currentProg):
	var moveList = get_used_cells()
	moveMap = {}
	for p in get_tree().get_nodes_in_group("Programs"):
		if p == currentProg:
			if Vector2(p.tileX, p.tileY) in moveList:
				moveList.erase(Vector2(p.tileX, p.tileY))
				moveMap[Vector2(p.tileX, p.tileY)] = 2
			for t in p.tailSectors:
				if Vector2(t.tileX, t.tileY) in moveList:
					moveList.erase(Vector2(t.tileX, t.tileY))
					moveMap[Vector2(t.tileX, t.tileY)] = 2
		if Vector2(p.tileX, p.tileY) in moveList:
			moveList.erase(Vector2(p.tileX, p.tileY))
		for t in p.tailSectors:
			if Vector2(t.tileX, t.tileY) in moveList:
				moveList.erase(Vector2(t.tileX, t.tileY))
	for i in moveList:
		moveMap[i] = 1

func findPath(a : Vector2, b : Vector2, distance = 0):
	if moveMap == null:
		_updateMoveMap(null)
	var cameFrom = {}
	var closed = []
	var open = [a]
	var gScore = {a:0} # distance from each tile to a
	var fScore = {a:10000} # approximate number of moves it takes to get from a to b through each tile
	var current
	while not open.empty():
		current = open[0]
		for o in open: # find the tile in the open set with the lowest fScore
			if fScore.has(o) and fScore[o] < fScore[current]:
				current = o
		if fScore[current] == gScore[current] + distance:
			return _reconstructPath(cameFrom, current)
		open.erase(current)
		closed.append(current)
		var gScoreTemp = gScore[current]+1
		for n in [Vector2(current.x+1, current.y), Vector2(current.x, current.y-1), Vector2(current.x-1, current.y), Vector2(current.x, current.y+1)]:
			if not moveMap.has(n):
				continue
			if closed.has(n):
				continue
			if not open.has(n): # this is a new tile
				open.append(n)
			elif gScoreTemp >= gScore[n]:
				continue
			# this is the new best path
			cameFrom[n] = current
			gScore[n] = gScoreTemp
			fScore[n] = gScoreTemp + abs(n.x-b.x) + abs(n.y-b.y)

func findPathGroup(a : Vector2, b : Array, distance = 0): # find the shortest path to any tile in b
	if moveMap == null:
		_updateMoveMap(null)
	var cameFrom = {}
	var closed = []
	var open = [a]
	var gScore = {a:0} # distance from each tile to a
	var fScore = {a:10000} # approximate number of moves it takes to get from a to b through each tile
	var current
	while not open.empty():
		current = open[0]
		for o in open: # find the tile in the open set with the lowest fScore
			if fScore.has(o) and fScore[o] < fScore[current]:
				current = o
		if fScore[current] == gScore[current] + distance: # if we found a tile the appropriate distance from the target
			return _reconstructPath(cameFrom, current)
		open.erase(current)
		closed.append(current)
		for n in [Vector2(current.x+1, current.y), Vector2(current.x, current.y-1), Vector2(current.x-1, current.y), Vector2(current.x, current.y+1)]:
			if not moveMap.has(n):
				continue
			if closed.has(n):
				continue
			var gScoreTemp = gScore[current]+moveMap[n]
			if not open.has(n): # this is a new tile
				open.append(n)
			elif gScoreTemp >= gScore[n]:
				continue
			# this is the new best path
			cameFrom[n] = current
			gScore[n] = gScoreTemp
			for i in b:
				var temp = gScoreTemp + abs(n.x-i.x) + abs(n.y-i.y)
				if not fScore.has(n) or temp < fScore[n]:
					fScore[n] = temp

func _reconstructPath(cameFrom : Dictionary, current : Vector2):
	var off = Vector2(1, 1)
	var path = [current]
	while current in cameFrom.keys():
		current = cameFrom[current]
		path.push_front(current)
	path.remove(0) # the path includes the program head's location, so we need to remove it
	return path
	
func findInRange(start: Vector2, targets, r: int):
	for t in targets:
		if abs(t.x-start.x)+abs(t.y-start.y) <= r:
			return t

func getProgramAtPoint(p):
	pass
