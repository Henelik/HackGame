extends Area2D

# Declare member variables here.
var tileX : int
var tileY : int
var dead : bool = false
var progColor : Color = Color(1, 1, 1, 1)
var deadColor : Color = Color(1, 1, 1, 0)
var t : float = 0
var deathRate : float = 10

func setColor(col : Color):
	$Sprite.modulate = col
	progColor = col
	
func die():
	dead = true

func _physics_process(delta):
	if dead:
		t += delta*deathRate
		$Sprite.modulate = progColor.linear_interpolate(deadColor, t)
		$Sprite.scale = $Sprite.scale.linear_interpolate(Vector2(2, 2), t)
		if t >= 1:
			queue_free()
