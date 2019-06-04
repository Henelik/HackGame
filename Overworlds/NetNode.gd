extends Node2D

export (String, FILE, "*.tscn") var battleScenePath

func _ready():
	pass

func _on_pressed():
	get_node("/root/GameRoot").loadBattle(battleScenePath)
