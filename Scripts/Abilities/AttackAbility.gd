extends "res://Scripts/Abilities/BaseAbility.gd"

export(int) var damage = 1

func _ready():
	pass

func fireProgram(target):
	target.damage(damage)
	_postFire()
	
func fireTile(tile: Vector2):
	pass
