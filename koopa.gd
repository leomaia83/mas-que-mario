extends Enemy
class_name Koopa

@export var shell_speed: float = 250.0
var in_a_shell: bool = false

func _ready() -> void:
	# Chama o setup do Enemy.gd para ativar o RayCast2D e variáveis base
	super._ready()
	
	# Ajustes específicos do Koopa
	self.speed = 40.0
	self.random_movement = false
	
	# --- CONFIGURAÇÃO DE COLISÃO ---
	# O Koopa deve estar na Layer 2 (Inimigos)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	
	# Procura o chão (1) e o Player (Mask 3)
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	
	if sprite and sprite is AnimatedSprite2D:
		sprite.play("walk")

func on_stomp(player_x: float):
	# Lógica chamada pelo Player ao cair no Koopa
	if not in_a_shell:
		enter_shell()
	else:
		if speed == 0: # Casco parado, vamos chutar
			var kick_dir = 1 if player_x < global_position.x else -1
			direction = kick_dir
			speed = shell_speed
			if sprite: sprite.play("shell_spinning")
		else: # Casco em movimento, vamos pará-lo
			speed = 0
			if sprite: sprite.play("shell")

func enter_shell():
	in_a_shell = true
	speed = 0
	
	# MUDANÇA DE CAMADA:
	# Para de ser Inimigo (3) e vira Casco (4)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, true)
	
	if sprite: 
		if sprite is AnimatedSprite2D:
			sprite.play("shell")
		else:
			sprite.scale.y = 0.6

func die():
	# O Koopa só morre (some) se já estiver no casco e for atingido 
	# ou se cair do mapa/levar dano de fogo
	if in_a_shell:
		super.die()
		queue_free()
	else:
		enter_shell()
