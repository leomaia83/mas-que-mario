extends Control

var udp := PacketPeerUDP.new()

func _ready() -> void:
	# 1. Tenta abrir a porta para o controle ESP32
	if udp.bind(4242) == OK:
		print("Menu: Aguardando sinal do controle...")
	else:
		print("Erro: Porta 4242 ocupada.")

	# 2. Conecta o clique do botão do mouse
	# Garanta que o nome do nó seja StartButton
	if has_node("StartButton"):
		$StartButton.pressed.connect(_on_start_pressed)

func _process(_delta: float) -> void:
	# 3. Verifica pacotes do ESP32 para começar o jogo pelo controle
	if udp.get_available_packet_count() > 0:
		var pacote = udp.get_packet().get_string_from_utf8()
		var dados = pacote.split(",")
		
		if dados.size() == 3:
			var btn_fogo = dados[2].to_int()
			if btn_fogo == 1:
				_on_start_pressed()

func _on_start_pressed() -> void:
	print("Botão apertado! Iniciando jogo...")
	GameManager.reset_game() # Zera vidas e score
	
	# MUITO IMPORTANTE: Verifique se o nome do arquivo da sua fase 
	# é "Main.tscn" ou "fase_1.tscn" e ajuste abaixo:
	get_tree().change_scene_to_file("res://Main.tscn") 

func _exit_tree() -> void:
	udp.close() # Libera a porta ao sair do menu
