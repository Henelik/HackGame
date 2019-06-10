extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var slowAmount = 1

func _ready():
	description = "Slows enemy by " + str(slowAmount) + " units per turn."

func fireProgram(target):
	if target.movesPerTurn > 0:
		target.movesPerTurn -= 1
	get_node("AbilitySound").play()
	_postFire()
	
func fireTile(tile: Vector2):
	return
#	get_node("AbilitySound").play()
#	_postFire()