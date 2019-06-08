extends Sprite

var dead : bool = false
var progColor : Color = Color(1, 1, 1, 1)
var deadColor : Color = Color(1, 1, 1, 0)
var t : float = 0
var deathRate : float = 10

func setColor(col : Color):
	modulate = col
	progColor = col

func die():
	dead = true

func _physics_process(delta):
	if dead:
		t += delta*deathRate
		modulate = progColor.linear_interpolate(deadColor, t)
		scale = scale.linear_interpolate(Vector2(2, 2), t)
		if t >= 1:
			queue_free()