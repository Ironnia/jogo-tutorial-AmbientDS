# =========================================================================
# SCRIPT: Tutorial.gd
# FUNÇÃO: Gerencia a lógica da cena de tutorial, que é uma versão
#         simplificada e guiada da cena principal do jogo.
# =========================================================================
extends Control

# --- Variáveis de Estado do Tutorial ---
var is_tutorial = false
var tutorial_step = 0
var passos_tutorial = [
	"Bem-vindo ao jogo! Seu objetivo é derrotar o chefão respondendo corretamente as perguntas.",
	"Cada pergunta aparecerá aqui no quadro cinza. Leia com atenção!",
	"Você terá 4 alternativas. Escolha a resposta correta.",
	"Se acertar, você causará dano ao chefão. Se errar, perderá vida.",
	"Essa é uma pergunta teste! Vamos ver como sua vida e a do chefão se comportam.",
	"Fim do tutorial! Clique no botão para voltar ao menu principal."
]
var health_bars_highlighted = false

# --- Variáveis e Referências (herdadas da lógica do jogo) ---
var player_health = 100
var boss_health = 100
@onready var pergunta_label = $"Mostrar texto"
@onready var botoes = [
	$VBoxContainer/GridContainer/Button,
	$VBoxContainer/GridContainer/Button2,
	$VBoxContainer/GridContainer/Button3,
	$VBoxContainer/GridContainer/Button4
]
@onready var player_health_bar = $CanvasLayer/PlayerHealthBar
@onready var boss_health_bar = $CanvasLayer/BossHealthBar
@onready var player_sprite = $"AnimatedSprite2D2-Phoenix"
@onready var boss_sprite = $"AnimatedSprite2D-Manfred"
@onready var botao_menu = $"Menu Principal"
@onready var botao_proximo = $BotaoProximo
@onready var botao_anterior = $BotaoAnterior
@onready var som_acerto = $Acertou
@onready var som_erro = $Errou


# Função chamada ao iniciar a cena.
func _ready():
	iniciar_tutorial()
	player_health_bar.value = player_health
	boss_health_bar.value = boss_health
	player_sprite.play("Idle-Phoenix")
	boss_sprite.play("Idle-Manfred")

# Configura o estado inicial do tutorial.
func iniciar_tutorial():
	is_tutorial = true
	tutorial_step = 0
	mostrar_tutorial()

# Atualiza a interface com o texto do passo atual do tutorial.
func mostrar_tutorial():
	pergunta_label.text = passos_tutorial[tutorial_step]

	# Lógica para destacar elementos na tela em passos específicos.
	if (tutorial_step == 3 or tutorial_step == 4) and not health_bars_highlighted:
		destacar_health_bars()

	# Controla a visibilidade dos botões de navegação.
	botao_anterior.visible = tutorial_step > 0
	botao_proximo.visible = tutorial_step < passos_tutorial.size() - 1
	botao_menu.visible = tutorial_step == passos_tutorial.size() - 1

	# Mostra os botões de alternativa apenas no passo da pergunta teste.
	for botao in botoes:
		botao.visible = tutorial_step == 4

	if tutorial_step == 4:
		mostrar_pergunta_teste()

# Animação para chamar atenção para as barras de vida.
func destacar_health_bars():
	health_bars_highlighted = true
	var tween = get_tree().create_tween()
	tween.tween_property(player_health_bar, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(player_health_bar, "scale", Vector2(1, 1), 0.5).set_delay(0.5)
	tween.tween_property(boss_health_bar, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(boss_health_bar, "scale", Vector2(1, 1), 0.5).set_delay(0.5)
	await get_tree().create_timer(1.5).timeout
	health_bars_highlighted = false

# Configura a pergunta de teste.
func mostrar_pergunta_teste():
	pergunta_label.text = "Pergunta teste: Qual é 2 + 2?"
	botoes[0].text = "3"
	botoes[1].text = "4"
	botoes[2].text = "5"
	botoes[3].text = "6"
	for botao in botoes:
		botao.disabled = false

# Processa a resposta da pergunta de teste.
func responder_pergunta_teste(indice):
	for botao in botoes:
		botao.disabled = true

	if indice == 1: # Resposta correta é "4" (índice 1).
		som_acerto.play()
		boss_health -= 20
		boss_health_bar.value = boss_health
		pergunta_label.text = "Resposta correta! Você causou dano ao chefão."
	else:
		som_erro.play()
		player_health -= 20
		player_health_bar.value = player_health
		pergunta_label.text = "Resposta errada! Você perdeu vida."

	await get_tree().create_timer(2).timeout
	proximo_passo_tutorial()

# Funções de navegação do tutorial.
func proximo_passo_tutorial():
	if tutorial_step < passos_tutorial.size() - 1 and not health_bars_highlighted:
		tutorial_step += 1
		mostrar_tutorial()

func passo_anterior_tutorial():
	if tutorial_step > 0:
		tutorial_step -= 1
		mostrar_tutorial()

# Conexão dos sinais dos botões de alternativa.
func _on_button_pressed():
	responder_pergunta_teste(0)
func _on_button_2_pressed():
	responder_pergunta_teste(1)
func _on_button_3_pressed():
	responder_pergunta_teste(2)
func _on_button_4_pressed():
	responder_pergunta_teste(3)

# Conexão dos sinais dos botões de navegação do tutorial.
func _on_botao_proximo_pressed():
	proximo_passo_tutorial()
func _on_botao_anterior_pressed():
	passo_anterior_tutorial()
	
# Conexão do botão de voltar ao menu.
func _on_menu_principal_pressed():
	get_tree().change_scene_to_file("res://Cenas/MenuPrincipal.tscn")
