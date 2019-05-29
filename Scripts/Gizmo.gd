extends Area2D

# Declare member variables here.
var owningNode
var tileX
var tileY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setColor(col):
	$Sprite.modulate = col
	
func setTexture(tex):
	$Sprite.texture = tex

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton\
	and event.button_index == BUTTON_LEFT\
	and event.pressed:
		owningNode.gizmoCallback(tileX, tileY)
