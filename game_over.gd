extends ColorRect

func _input(event):
	# Se o jogador apertar qualquer tecla ou botão do ESP32 (que simula tecla)
	if event is InputEventKey or event is InputEventMouseButton:
		get_tree().change_scene_to_file("res://fase_1.tscn") # Volta para a primeira fase
