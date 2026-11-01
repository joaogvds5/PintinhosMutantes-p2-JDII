#código para mostrar a quantidade de vidas, progresso da missão (ficar dentro da área segura) e mensagens de finalização da partida
extends CanvasLayer

var rotulo_de_vida: Label
var rotulo_de_territorio: Label
var rotulo_de_mensagem: Label
var barra_de_territorio: ProgressBar

func _ready() -> void:
	rotulo_de_vida = get_node_or_null("HealthLabel")
	rotulo_de_territorio = get_node_or_null("TerritoryLabel")
	rotulo_de_mensagem = get_node_or_null("MessageLabel")
	barra_de_territorio = get_node_or_null("TerritoryBar")
	if rotulo_de_mensagem:
		rotulo_de_mensagem.text = ""

func atualizar_vida(vida_atual: int, vida_maxima: int) -> void:
	#mostra a quantidade de vidas restantes/total de vidas
	if rotulo_de_vida == null:
		return
	rotulo_de_vida.text = "Vida: %d/%d" % [vida_atual, vida_maxima]

func atualizar_territorio(tempo_atual: float, tempo_alvo: float) -> void:
	#atualizar o texto e progesso dentro d area segura
	if rotulo_de_territorio:
		rotulo_de_territorio.text = "Território: %.1f / %.0f s" % [tempo_atual, tempo_alvo]
	if barra_de_territorio:
		barra_de_territorio.max_value = tempo_alvo
		barra_de_territorio.value = tempo_atual

func mostrar_mensagem(texto: String) -> void:
	#mensagem de finalização, seja vitória ou derrota
	if rotulo_de_mensagem:
		rotulo_de_mensagem.text = texto