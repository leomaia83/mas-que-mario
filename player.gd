extends CharacterBody2D
class_name Player

enum PlayerMode { SMALL, BIG, SHOOTING }

@export_group("Locomotion")
@export var speed: float = 150.0
@export var jump_velocity: float = -500.0
@export var run_speed_damping: float = 10.0

@export_group("Stomping")
@export var stomp_y_velocity: float = -300.0

@export_group("Power Ups")
@export var is_fire_mario: bool = false # Agora aparece no Inspetor!

@onready var animated_sprite = $AnimatedSprite2D
@onready var score_label = get_tree().current_scene.find_child("ScoreLabel", true, false)
@onready var lives_label = get_tree().current_scene.find_child("LivesLabel", true, false)

var udp := PacketPeerUDP.new()
var esp_direction: float = 0.0
var esp_jump: bool = false
var esp_fire: bool = false

var player_mode = PlayerMode.SMALL
var is_dead: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var points_label_scene = preload("res://points_label.tscn")
const FIREBALL_SCENE = preload("res://fireball.tscn") 

func _input(event):
	# Tiro pelo teclado (Espaço/Enter)
	if is_fire_mario and Input.is_action_just_pressed("ui_accept"): 
		shoot()

func shoot():
	var fireball = FIREBALL_SCENE.instantiate()
	# Ajusta a posição de saída para não colidir com o próprio Mario
	fireball.global_position = global_position + Vector2(10 if !animated_sprite.flip_h else -10, 0)
	fireball.direction = -1 if animated_sprite.flip_h else 1
	get_parent().add_child(fireball)

func _ready() -> void:
	if udp.bind(4242) == OK:
		print("Controle ESP32 conectado!")
	
	if has_node("Hitbox"):
		$Hitbox.area_entered.connect(_on_hitbox_area_entered)

	if lives_label:
		lives_label.text = "LIVES: " + str(GameManager.lives)
		
func _physics_process(delta: float) -> void:
	if is_dead: return
	process_esp_input()

	# Lógica de tiro pelo ESP32
	if is_fire_mario and esp_fire:
		shoot()
		esp_fire = false # Reseta para não atirar infinitamente

	if not is_on_floor():
		velocity.y += gravity * delta

	if (Input.is_action_just_pressed("jump") or esp_jump) and is_on_floor():
		velocity.y = jump_velocity
		esp_jump = false
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	var keyboard_dir = Input.get_axis("left", "right")
	var direction = keyboard_dir if keyboard_dir != 0 else esp_direction
	
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, run_speed_damping * delta)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)

	move_and_slide()
	update_animations(direction)

func process_esp_input():
	if udp.get_available_packet_count() > 0:
		var pacote = udp.get_packet().get_string_from_utf8()
		var dados = pacote.split(",")
		if dados.size() == 3:
			var x_joy = dados[0].to_int()
			var y_joy = dados[1].to_int()
			var btn_fogo = dados[2].to_int()
			
			if x_joy < 1500: esp_direction = -1.0
			elif x_joy > 2500: esp_direction = 1.0
			else: esp_direction = 0.0
			
			esp_jump = (y_joy < 1000)
			esp_fire = (btn_fogo == 1)

func update_animations(direction):
	if is_dead: return
	
	# Sufixo para mudar a animação se for Mario de Fogo
	var suffix = "_fire" if is_fire_mario else ""
	
	if not is_on_floor():
		animated_sprite.play("jump" + suffix)
	elif direction != 0:
		animated_sprite.play("walk" + suffix)
	else:
		animated_sprite.play("idle" + suffix)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("die"):
		handle_enemy_collision(area)

func handle_enemy_collision(enemy):
	if enemy is Koopa and enemy.in_a_shell:
		enemy.on_stomp(global_position.x)
		add_score(100)
		velocity.y = stomp_y_velocity * 0.5
		return
	
	if velocity.y > 0 and global_position.y < enemy.global_position.y:
		add_score(100)
		if enemy.has_method("on_stomp"):
			enemy.on_stomp(global_position.x)
		else:
			enemy.die()
		velocity.y = stomp_y_velocity
	else:
		die()

func add_score(amount: int):
	GameManager.score += amount
	
	if score_label:
		score_label.text = "SCORE: " + str(GameManager.score)
	var p_label = points_label_scene.instantiate()
	p_label.text = str(amount)
	p_label.global_position = global_position + Vector2(-10, -30)
	get_tree().current_scene.add_child(p_label)

func die():
	if is_dead: return
	is_dead = true
	GameManager.lives -= 1
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	animated_sprite.play("small_death")
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y - 100, 0.4)
	tween.tween_property(self, "position:y", position.y + 500, 1.0)
	
	tween.tween_callback(func():
		if GameManager.lives > 0:
			get_tree().reload_current_scene()
		else:
			print("GAME OVER")
			GameManager.reset_game() 
			get_tree().change_scene_to_file("res://game_over.tscn"))
			
