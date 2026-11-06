extends CharacterBody2D
class_name Enemy

@export var speed: float = -50.0
@export var gravity: int = 980
var direction: int = 1
var is_destroyed: bool = false

func _physics_process(delta: float) -> void:
	# 1. Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0 # Garante que a velocidade vertical não acumule no chão
	
	# 2. Movimento
	if not is_destroyed:
		velocity.x = speed * direction
	else:
		velocity.x = move_toward(velocity.x, 0, 10)

	# 3. Execução da Física (O essencial)
	move_and_slide()

	# 4. Detecção de Parede e Virada
	# Usamos is_on_wall() APÓS o move_and_slide()
	if is_on_wall() and not is_destroyed:
		direction *= -1
		# Otimização: Inverter o scale.x pode bugar a física se não for centralizado. 
		# Se preferir, use $AnimatedSprite2D.flip_h = ! $AnimatedSprite2D.flip_h
		scale.x = abs(scale.x) * -direction 

func die():
	is_destroyed = true
	# Camadas de colisão (Ajuste conforme seu projeto)
	set_collision_layer_value(3, false) 
	set_collision_mask_value(1, false)
