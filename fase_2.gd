extends Node2D

func _ready() -> void:
	# Isso ativa o poder assim que a fase carrega
	$Player.is_fire_mario = true
	# Opcional: já inicia com a animação de fogo se você a criou
	$Player.get_node("AnimatedSprite2D").play("shooting_jump")
