extends "res://Scripts/Abilities/BaseAbility.gd"

func fireProgram(target):
	return
	
func fireTile(tile: Vector2):
	get_node("AbilitySound").play()
	get_parent().move(tile.x, tile.y)
	_postFire()

func checkRange(target: Vector2):
	var battleMap = get_node("/root/GameRoot/Battle/BattleMap")
	if abs(target.x-tileX)+abs(target.y-tileY) <= maxRange and not (target.x == tileX and target.y == tileY) and target in battleMap.get_used_cells():
		return true
	return false
