extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var tileValue = -1

func fireProgram(target):
	return
	
func fireTile(tile: Vector2):
	var tm = get_node("/root/GameRoot/Battle/BattleMap")
	print("Tile was " + str(tm.get_cellv(tile)))
	get_node("AbilitySound").play()
	tm.set_cellv(tile, tileValue)
	print("Tile is now " + str(tileValue))
	_postFire()
