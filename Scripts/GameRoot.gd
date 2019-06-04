extends Node2D

var currentOverworld
var currentBattle

func _ready():
	loadOverworld("res://Overworlds/OverworldTest.tscn")
	
func unload():
	if currentOverworld != null:
		remove_child(currentOverworld)
		currentOverworld.queue_free()
		currentOverworld = null
	if currentBattle != null:
		remove_child(currentBattle)
		currentBattle.queue_free()
		currentBattle = null
	
func loadOverworld(path : String):
	unload()
	currentOverworld = load(path).instance()
	add_child(currentOverworld)
	
func loadBattle(path : String):
	unload()
	currentBattle = load(path).instance()
	add_child(currentBattle)
	
func battleCallback(winner : int, unlockedNode : bool, credits = 0):
	pass
