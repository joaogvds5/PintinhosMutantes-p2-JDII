#área segura -> acumula tempo enquanto o player estiver dentro e muda de lugar
#de tempos para forçar o jogador a se movimentar pelo mapa
extends Area2D

#parametros que configuram a dificuldade do jogo
@export var tempo_para_vitoria: float = 60.0
@export var intervalo_de_mudanca: float = 10.0
@export var retangulo_da_arena: Rect2 = Rect2(64, 64, 512, 352)
@export var raio_da_zona: float = 48.0

#estado interno que se altera ao longo da partida
var tempo_acumulado: float = 0.0
var player_dentro: bool = false
var contador_para_mudar: float = 0.0

signal progresso_alterado(atual: float, alvo: float)
signal zona_mudou

func _ready() -> void:
	#conecta os sinais de entrada/saída para detectar o player
	body_entered.connect(_ao_entrar_corpo)
	body_exited.connect(_ao_sair_corpo)
	contador_para_mudar = intervalo_de_mudanca
	_mudar_de_lugar()
	_atualizar_visual()

func _process(delta: float) -> void:
	#conforme o player está dentro, acumula tempo e atualiza a HUD com o progresso alterado
	if player_dentro:
		tempo_acumulado = min(tempo_acumulado + delta, tempo_para_vitoria)
		progresso_alterado.emit(tempo_acumulado, tempo_para_vitoria)
		_atualizar_visual()
		if tempo_acumulado >= tempo_para_vitoria:
			get_tree().call_group("game_manager", "ao_vitoria")

	#conta o tempo até a proxima mudança de lugar da área segura
	contador_para_mudar -= delta
	if contador_para_mudar <= 0.0:
		contador_para_mudar = intervalo_de_mudanca
		_mudar_de_lugar()

func _mudar_de_lugar() -> void:
	#soterio de uma posição dentro do mapa, considerando margem para não encostar na parede
	var margem := raio_da_zona + 8.0
	var min_x := retangulo_da_arena.position.x + margem
	var max_x := retangulo_da_arena.end.x - margem
	var min_y := retangulo_da_arena.position.y + margem
	var max_y := retangulo_da_arena.end.y - margem
	global_position = Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)
	zona_mudou.emit()

func _atualizar_visual() -> void:
	#mais próximo da vitória, muda o visual da zona segura
	var proporcao := tempo_acumulado / tempo_para_vitoria
	modulate = Color(1.0, 1.0 - 0.6 * proporcao, 0.3 + 0.7 * proporcao, 0.35)

func _ao_entrar_corpo(corpo: Node2D) -> void:
	#conta tempo se quem entrou foi o player
	if corpo.is_in_group("player"):
		player_dentro = true

func _ao_sair_corpo(corpo: Node2D) -> void:
	#ao sair da zona segura para de acumular sem zerar o tempo já conquistado
	if corpo.is_in_group("player"):
		player_dentro = false