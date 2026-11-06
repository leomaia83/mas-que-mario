extends Area2D

func _ready() -> void:
	# Isso garante que o sinal está conectado via código, 
	# caso a conexão visual do editor tenha falhado.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Print para confirmar no console que a KillZone sentiu algo
	print("Objeto detectado no buraco: ", body.name)
	
	# Verifica se o corpo que caiu é o Player (ou tem a função die)
	if body.has_method("die"):
		print("Player detectado! Chamando função de morte...")
		body.die()
