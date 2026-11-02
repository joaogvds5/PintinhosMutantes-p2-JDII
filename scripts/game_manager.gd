extends Node

@onready var hud: CanvasLayer = $"../HUD"
@onready var player: CharacterBody2D = $"../Player"
@onready var zona: Area2D = $"../TerritoryZone"

func _ready() -> void:
	add_to_group("game_manager")
	#conecta os sinais de mudanças de vida e de progresso atualizam a HUD
	player.vida_alterada.connect(hud.atualizar_vida)
	player.morreu.connect(ao_derrota)
	zona.progresso_alterado.connect(hud.atualizar_territorio)
	call_deferred("_atualizar_hud_inicial")

func _atualizar_hud_inicial() -> void:
	#inicia partida com as informações do HUD, quantidade de vidas e progresso 
	#do tempo até a vitoria
	hud.atualizar_vida(player.vida_atual, player.vida_maxima)
	hud.atualizar_territorio(0.0, zona.tempo_para_vitoria)

func ao_vitoria() -> void:
	#trava o jogo e encerra com mensagem de vitoria
	if get_tree().paused:
		return
	get_tree().paused = true
	hud.mostrar_mensagem("Território conquistado! Você venceu.")

func ao_derrota() -> void:
	#trava o jogo e encerra com mensagem de derrota
	if get_tree().paused:
		return
	get_tree().paused = true
	hud.mostrar_mensagem("Os pintinhos mutantes dominaram o galinheiro. Fim de jogo.")