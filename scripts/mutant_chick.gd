#máquina de estados (parado, perseguindo, atacando, recuando)
extends CharacterBody2D

#possíveis estadis  do inimigo
enum Estado { PARADO, PERSEGUINDO, ATACANDO, RECUANDO }

#opções de tema dos mutantes que  serão sorteados
const TEXTURAS := [
	preload("res://imgs/pintinho_mutante.svg"),
	preload("res://imgs/pintinho_mutante1.svg"),
	preload("res://imgs/pintinho_mutante2.svg"),
]

#parametros dos inimigos mutantes - afeta a dificuldade
@export var velocidade: float = 60.0
@export var vida_maxima: int = 2
@export var dano_do_ataque: int = 1
@export var recarga_do_ataque: float = 1.2
@export var raio_de_deteccao: float = 260.0
@export var alcance_do_ataque: float = 28.0
@export var duracao_do_recuo: float = 0.4
@export var comprimento_da_sonda: float = 28.0

var estado: Estado = Estado.PARADO
var vida_atual: int
var player_alvo: Node2D
var contador_de_ataque: float = 0.0
var contador_de_recuo: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	#inicia com a vida que poderá ser decrementada por meio do ataque do player 
	vida_atual = vida_maxima
	add_to_group("enemies")
	#sorteio da textura para o mutante
	if sprite:
		sprite.texture = TEXTURAS[randi() % TEXTURAS.size()]

func _physics_process(delta: float) -> void:
	#atualiza a recarga do ataque e busca sempre pelo jogador
	contador_de_ataque = max(0.0, contador_de_ataque - delta)
	player_alvo = _procurar_player()

	#verifica estado atual
	match estado:
		Estado.PARADO:      _estado_parado()
		Estado.PERSEGUINDO: _estado_perseguindo(delta)
		Estado.ATACANDO:    _estado_atacando(delta)
		Estado.RECUANDO:    _estado_recuando(delta)

	#aplica velocidade definida em cada estado
	move_and_slide()

func _procurar_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null

func _estado_parado() -> void:
	#imóvel até que o player entre no 'campo de detecção' do mutante
	velocity = Vector2.ZERO
	if player_alvo and global_position.distance_to(player_alvo.global_position) < raio_de_deteccao:
		estado = Estado.PERSEGUINDO

func _estado_perseguindo(_delta: float) -> void:
	#persegue player; se tiver na distância menor q do alcance de ataque, significa dano ao player
	if not player_alvo:
		estado = Estado.PARADO
		return
	var direcao_ate_player := (player_alvo.global_position - global_position)
	if direcao_ate_player.length() < alcance_do_ataque:
		estado = Estado.ATACANDO
		return
	velocity = _desviar_de_obstaculos(direcao_ate_player.normalized()) * velocidade

func _desviar_de_obstaculos(desejada: Vector2) -> Vector2:
	#lança um raio curto à frente; 
	#se bater em parede, desvia para o lado que estiver mais perto do player
	var espaco := get_world_2d().direct_space_state
	var origem := global_position
	var destino := global_position + desejada * comprimento_da_sonda
	var consulta := PhysicsRayQueryParameters2D.create(origem, destino)
	consulta.exclude = [get_rid()]
	consulta.collision_mask = 4  # apenas a camada "walls"
	var colisao := espaco.intersect_ray(consulta)
	if colisao.is_empty():
		return desejada  # caminho livre: segue reto
	var perpendicular := Vector2(-desejada.y, desejada.x)
	if player_alvo and (global_position + perpendicular).distance_to(player_alvo.global_position) > \
			(global_position - perpendicular).distance_to(player_alvo.global_position):
		perpendicular = -perpendicular
	return (desejada + perpendicular).normalized()

func _estado_atacando(_delta: float) -> void:
	#para de andar, causa dano se não tiver em cooldown  e recua em seguida'
	velocity = Vector2.ZERO
	if contador_de_ataque <= 0.0 and player_alvo:
		player_alvo.receber_dano(dano_do_ataque)
		contador_de_ataque = recarga_do_ataque
		contador_de_recuo = duracao_do_recuo
		estado = Estado.RECUANDO
		return
	#player se afastou -> volta a perseguir
	if player_alvo and global_position.distance_to(player_alvo.global_position) > alcance_do_ataque * 1.2:
		estado = Estado.PERSEGUINDO

func _estado_recuando(delta: float) -> void:
	contador_de_recuo -= delta
	if player_alvo:
		velocity = (global_position - player_alvo.global_position).normalized() * velocidade
	if contador_de_recuo <= 0.0:
		estado = Estado.PERSEGUINDO

func receber_dano_em_raio(centro: Vector2, raio: float, dano: int) -> void:
	#só toma dano se estiver dentro do raio
	if global_position.distance_to(centro) <= raio:
		vida_atual -= dano
		if vida_atual <= 0:
			queue_free()