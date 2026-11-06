extends Area2D
class_name Enemy

# --- Referências ---
@onready var floor_detector = $RayCast2D
# Procura automaticamente qualquer nó que tenha "Sprite" no nome
@onready var sprite = find_child("*Sprite*") 

# --- Configurações ---
@export_group("Movement")
@export var speed: float = 40.0
@export var fall_gravity: float = 0
@export var direction: int = -1

@export_group("Behavior")
@export var random_movement: bool = false # Recomendado FALSE para Goombas comuns
@export var min_time: float = 2.0
@export var max_time: float = 5.0

var change_direction_timer: float = 0.0
var is_destroyed: bool = false
var velocity_y: float = 0.0
var is_on_floor: bool = false

func _ready() -> void:
	if floor_detector:
		floor_detector.enabled = true
		floor_detector.add_exception(self)
	change_direction_timer = randf_range(min_time, max_time)

func _physics_process(delta: float) -> void:
	if is_destroyed: return

	# 1. Movimento Aleatório (se ativado no Inspector)
	if random_movement:
		change_direction_timer -= delta
		if change_direction_timer <= 0:
			direction *= -1
			change_direction_timer = randf_range(min_time, max_time)

	# 2. Gravidade Manual para Area2D
	if not is_on_floor:
		velocity_y += fall_gravity * delta
	else:
		velocity_y = 0

	position.y += velocity_y * delta
	position.x += speed * direction * delta

	# 3. Alinhamento com o Solo (Raycast)
	if floor_detector and floor_detector.is_colliding():
		var col_point = floor_detector.get_collision_point()
		# Ajuste de "snapping" para não tremer
		if global_position.y >= col_point.y - 2:
			global_position.y = col_point.y
			is_on_floor = true
			velocity_y = 0
		else:
			is_on_floor = false
	else:
		is_on_floor = false
	
	# 4. Inverter Sprite conforme direção
	if sprite:
		sprite.flip_h = (direction > 0)

func die():
	if is_destroyed: return
	is_destroyed = true
	speed = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
