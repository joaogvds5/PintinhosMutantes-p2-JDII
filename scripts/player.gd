#controle da galinha protagonista (jogador)
#movimenta nas 4 direções utilizando 

	#pra cima: ↑ (seta pra cima)
	#pra pra baixo: ↓ (seta pra baixo)
	#pra direita : → (seta pra direita)
	#pra esquerda: ← (seta pra esquerda)


#controla a quantidade de vidas (-1 a cada galinha que o toca) restante/toral da galinha

extends CharacterBody2D

#parametros que afetam a dificuldade do jogo
@export var velocidade: float = 180.0
@export var vida_maxima: int = 8 
@export var raio_de_ataque: float = 56.0
@export var recarga_do_ataque: float = 0.35

var vida_atual: int
var pode_atacar: bool = true

signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu

func _ready() -> void:
	#inicia a vida máxima
	vida_atual = vida_maxima
	add_to_group("player")
	vida_alterada.emit(vida_atual, vida_maxima)

func _physics_process(_delta: float) -> void:
	#leitura das teclas que o usuário aperta para direcionar o jogador
	var direcao := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	velocity = direcao.normalized() * velocidade
	move_and_slide()

	#ataque em recarga
	if Input.is_action_just_pressed("attack") and pode_atacar:
		_atacar()

func _atacar() -> void:
	pode_atacar = false
	get_tree().call_group("enemies", "receber_dano_em_raio",
		global_position, raio_de_ataque, 1)
	#espera o tempo de recarga do ataque para que a galinha possa perder vida novamente se tocada
	await get_tree().create_timer(recarga_do_ataque).timeout
	pode_atacar = true

func receber_dano(quantidade: int) -> void:
	#se a vida for maior que zero e recebeu toque de um mutante, perde 1 de vida
	#se vida menor q zero, apenas retorna.
	#se zerado, finaliza.
	if vida_atual <= 0:
		return
	vida_atual = max(0, vida_atual - quantidade)
	vida_alterada.emit(vida_atual, vida_maxima)
	if vida_atual == 0:
		morreu.emit()