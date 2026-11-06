extends Enemy

func _ready() -> void:
	# Chama a configuração inicial do pai (Enemy.gd)
	super._ready()
	
	# Ajustes específicos do Goomba
	self.speed = 35.0
	self.random_movement = true
	
	# --- CONFIGURAÇÃO DE COLISÃO VIA CÓDIGO ---
	# No _ready do Goomba
	set_collision_layer_value(1, false) 
	set_collision_layer_value(3, true)  # Ele é um Enemy (Camada 3)
	set_collision_mask_value(2, true)   # Ele caminha sobre o Ground (Camada 2)
	
	# Configuração visual
	if sprite and sprite is AnimatedSprite2D:
		sprite.play("walk")

func die():
	# Sobrescreve a função de morte para o efeito de esmagado
	if is_destroyed: return
	is_destroyed = true
	speed = 0
	
	# Desativa o sensor de chão para o Goomba "parar" no sítio onde morreu
	if floor_detector: 
		floor_detector.enabled = false
	
	if sprite:
		if sprite is AnimatedSprite2D and sprite.sprite_frames.has_animation("dead"):
			sprite.play("dead")
		else:
			# Efeito visual manual caso não haja animação "dead"
			sprite.scale.y = 0.2
			sprite.position.y += 12
			
	# MUITO IMPORTANTE: Desativa as detecções para o Player não morrer 
	# ao tocar no Goomba que já está morto
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Aguarda um pouco antes de remover o nó da cena
	await get_tree().create_timer(0.5).timeout
	queue_free()
