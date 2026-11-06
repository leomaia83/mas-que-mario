extends Area2D

var speed = 400
var direction = 1 

func _ready():
	# Isso conecta o sinal na marra via código, ignorando o que está no editor
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	position.x += speed * direction * delta

func _on_area_entered(area: Area2D) -> void:
	print("!!! ENCOSTOU EM ALGO !!! Nome: ", area.name)
	
	# Se ele não reconhecer o grupo, vamos matar pelo nome só pra testar
	if area.is_in_group("enemies") or "Koopa" in area.name or "Goomba" in area.name:
		print("Inimigo detectado com sucesso!")
		if area.has_method("die"):
			area.die()
		else:
			area.queue_free() # Se não tiver a função, ele some do mapa na força
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Se bater no chão (Mask 2), ela apenas some
	print("Bateu no chão/parede")
	queue_free()
