extends Particles2D
var dest: Vector2
	
func setDestination(x):
	self.dest = x

func emit(piecePositiion: Vector2):
	position = piecePositiion
	var distanceVector = Vector3(dest.x - position.x, dest.y - position.y, 0)
	process_material.direction = distanceVector
	var distance = sqrt(pow(distanceVector.x,2)+ pow(distanceVector.y,2))
	var ltime = distance/process_material.initial_velocity
	amount = distance/40
	preprocess = 0.001*distance
	lifetime = ltime
	emitting = true
	yield(get_tree().create_timer(5.0), "timeout")
	queue_free()
