extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var damage = 1

func fireProgram(target):
	target.damage(damage)
	get_node("AttackSound").play()
	_postFire()
	
func fireTile(tile: Vector2):
	get_node("AttackSound").play()
	_postFire()
