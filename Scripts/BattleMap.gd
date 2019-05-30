extends TileMap

var moveMap

func _ready():
	pass

func _updateMoveMap(ignoreProg):
	moveMap = get_used_cells()
	for p in get_tree().get_nodes_in_group("Programs"):
		if p == ignoreProg:
			continue
		if Vector2(p.tileX, p.tileY) in moveMap:
			moveMap.erase(Vector2(p.tileX, p.tileY))
		for t in p.tailSectors:
			if Vector2(t.tileX, t.tileY) in moveMap:
				moveMap.erase(Vector2(t.tileX, t.tileY))

func findPath(a : Vector2, b : Vector2):
	var cameFrom = {}
	var closed = []
	var open = [a]
	var gScore = {a:0}
	var fScore = {}
	var current
	while not open.empty():
		current = open[0]
		for o in open:
			if fScore.has(o) and fScore[o] < fScore[current]:
				current = o
		if current == b:
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

func _reconstructPath(cameFrom, current):
	var off = Vector2(1, 1)
	var path = [current]
	while current in cameFrom.keys():
		current = cameFrom[current]
		path.push_front(current)
	path.remove(0) # the path includes the program head's location, so we need to remove it
	return path

func getProgramAtPoint(p):
	pass
