extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var slowAmount = 1

func fireProgram(target):
	if target.movePerTurn > 0:
		target.movesPerTurn -= 1
	get_node("AbilitySound").play()
	_postFire()
	
func fireTile(tile: Vector2):
	return
#	get_node("AbilitySound").play()
#	_postFire()