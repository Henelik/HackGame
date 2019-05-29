extends KinematicBody2D

# Declare member variables here.
var speed = 350
var velocity = Vector2()
export(Array, int) var playerTypes # 0 is local, 1 is AI, 2 is online
var currentPlayer # an index of the array
var selectedProgram

# Called when the node enters the scene tree for the first time.
func _ready():
	var programs = get_tree().get_nodes_in_group("Programs")
	currentPlayer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	velocity.y = int(Input.is_action_pressed("ui_down"))-int(Input.is_action_pressed("ui_up"))
	move_and_slide(velocity.normalized() * speed)

func _on_EndTurnButton_pressed():
	print("Ending turn...")
	
