extends Label

func _ready():
	var label_tween = get_tree().create_tween()
	
	# 1. Faz subir 10 pixels em 0.4 segundos
	label_tween.tween_property(self, "position", position + Vector2(0, -10), 0.4)
	
	# 2. SÓ DEPOIS que subir, ele chama o queue_free para deletar
	label_tween.tween_callback(queue_free)
