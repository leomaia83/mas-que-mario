extends AnimatedSprite2D
class_name PlayerAnimatedSprite

func trigger_animation(velocity: Vector2, direction: float, mode: Player.PlayerMode):
	var suffix = Player.PlayerMode.keys()[mode].to_lower()
	
	if not get_parent().is_on_floor():
		play(suffix + "_jump")
	elif direction != 0 and sign(velocity.x) != sign(direction):
		play(suffix + "_slide")
	elif velocity.x != 0:
		play(suffix + "_run")
		flip_h = velocity.x < 0
	else:
		play(suffix + "_idle")
