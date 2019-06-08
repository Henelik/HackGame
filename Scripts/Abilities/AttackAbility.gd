extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var damage = 1

func _ready():
	description = "Deals " + str(damage) + " damage to target program."

func fireProgram(target):
	get_node("AttackSound").play()
	yield(target.damage(damage), "completed")
	_postFire()
	
func fireTile(tile: Vector2):
	return
#	get_node("AttackSound").play()
#	_postFire()
