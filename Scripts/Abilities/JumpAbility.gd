extends "res://Scripts/Abilities/BaseAbility.gd"

func fireProgram(target):
	return
	
func fireTile(tile: Vector2):
	get_node("AbilitySound").play()
	get_parent().move(tile.x, tile.y)
	_postFire()
