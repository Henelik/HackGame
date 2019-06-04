extends Node2D

var currentOverworld
var currentBattle

func _ready():
	currentOverworld = load("res://Overworlds/OverworldTest.tscn").instance()
	add_child(currentOverworld)
