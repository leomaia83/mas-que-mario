extends Area2D

# 1. A variável que você vai mudar NO INSPETOR de cada fase
@export_file("*.tscn") var proxima_fase

# 2. A função de colisão (CERTIFIQUE-SE DE CONECTAR O SINAL 'body_entered')
func _on_body_entered(body: Node2D) -> void:
	# Verifica se é o Player que encostou
	if body.is_in_group("player") or body.name == "Player":
		if proxima_fase != "":
			print("Indo para a próxima fase: ", proxima_fase)
			get_tree().change_scene_to_file(proxima_fase)
		else:
			print("ERRO: Você esqueceu de selecionar o arquivo da fase no Inspetor!")
