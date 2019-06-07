extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var damage = 1

func fireProgram(target):
	get_node("AttackSound").play()
	yield(target.damage(damage), "completed")
	_postFire()
	
func fireTile(tile: Vector2):
	return
	get_node("AttackSound").play()
	_postFire()
