#gerador pintinhos mutantes nas bordas do terreno. O intervalo entre spawns
extends Node

#parametros de spawn, afetando também a dificuldade
@export var cena_do_inimigo: PackedScene
@export var retangulo_da_arena: Rect2 = Rect2(64, 64, 512, 352)
@export var intervalo_inicial: float = 2.5
@export var intervalo_minimo: float = 0.9
@export var segundos_para_atingir_o_minimo: float = 90.0
@export var maximo_de_inimigos_vivos: int = 18

var tempo_decorrido: float = 0.0
var contador_para_spawn: float = 0.0

func _ready() -> void:
	if cena_do_inimigo == null:
		cena_do_inimigo = preload("res://scenes/MutantChick.tscn")

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	tempo_decorrido += delta

	#verificando se atingiu o limite de inimigos (mutantes) vivos
	if get_tree().get_nodes_in_group("enemies").size() >= maximo_de_inimigos_vivos:
		return

	#contador de tempo até o próximo spawn
	contador_para_spawn -= delta
	if contador_para_spawn <= 0.0:
		contador_para_spawn = _calcular_intervalo_atual()
		_criar_inimigo()

func _calcular_intervalo_atual() -> float:
	var proporcao := clampf(tempo_decorrido / segundos_para_atingir_o_minimo, 0.0, 1.0)
	return lerpf(intervalo_inicial, intervalo_minimo, proporcao)

func _criar_inimigo() -> void:
	#instancia  o inimigo e o posiciona na borda 
	var inimigo := cena_do_inimigo.instantiate()
	inimigo.global_position = _sortear_ponto_da_borda()
	get_tree().current_scene.add_child(inimigo)

func _sortear_ponto_da_borda() -> Vector2:
	#sorteia um dos 4 lados do mapa
	var lado := randi() % 4
	match lado:
		0: return Vector2(retangulo_da_arena.position.x, randf_range(retangulo_da_arena.position.y, retangulo_da_arena.end.y))
		1: return Vector2(retangulo_da_arena.end.x,     randf_range(retangulo_da_arena.position.y, retangulo_da_arena.end.y))
		2: return Vector2(randf_range(retangulo_da_arena.position.x, retangulo_da_arena.end.x), retangulo_da_arena.position.y)
		_: return Vector2(randf_range(retangulo_da_arena.position.x, retangulo_da_arena.end.x), retangulo_da_arena.end.y)