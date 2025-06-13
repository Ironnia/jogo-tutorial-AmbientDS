extends Control

var perguntas = []
var pergunta_atual = 0
var resposta_correta = -1
var gabarito = []
var indice_gabarito = 0

var player_health = 100
var boss_health = 100

@onready var pergunta_label = $RichTextLabel
@onready var botoes = [
	$VBoxContainer/Button,
	$VBoxContainer/Button2,
	$VBoxContainer/Button3,
	$VBoxContainer/Button4
]
@onready var player_sprite = $AnimatedSprite2D
@onready var boss_sprite = $AnimatedSprite2D2

@onready var player_health_bar = $phoenix
@onready var boss_health_bar = $Manfred

@onready var resumo_label = $RichTextLabel
@onready var botao_proximo = $Proximo
@onready var botao_anterior = $Anterior
@onready var botao_menu = $Menu

func _ready():
	carregar_perguntas()
	mostrar_pergunta()
	
	player_health_bar.max_value = 100
	boss_health_bar.max_value = 100
	player_health_bar.value = player_health
	boss_health_bar.value = boss_health
	
	botao_proximo.visible = false
	botao_anterior.visible = false
	botao_menu.visible = false
	player_sprite.play("Parado")
	boss_sprite.play("Manfred")

func carregar_perguntas():
	var config = ConfigFile.new()
	var erro = config.load("user://config.cfg")
	var arquivo_perguntas = "perguntas.txt"
	
	if erro == OK:
		arquivo_perguntas = config.get_value("Jogo", "arquivo_perguntas", "perguntas.txt")
	
	var file = FileAccess.open("res://" + arquivo_perguntas, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var linha = file.get_line()
			var partes = linha.split("|")
			if partes.size() == 6:
				perguntas.append(partes)
		perguntas.shuffle()
	else:
		pergunta_label.text = "Erro ao carregar perguntas."

func mostrar_pergunta():
	if pergunta_atual < perguntas.size():
		pergunta_label.visible = true
		for botao in botoes:
			botao.visible = true

		var pergunta_data = perguntas[pergunta_atual]
		pergunta_label.bbcode_enabled = true
		pergunta_label.text = "[center]" + pergunta_data[0] + "[/center]"
		resposta_correta = int(pergunta_data[5]) - 1
		
		for i in range(botoes.size()):
			botoes[i].text = pergunta_data[i + 1]
			botoes[i].disabled = false
		
		player_sprite.play("Parado")
		boss_sprite.play("Manfred")
	else:
		mostrar_resumo()

func responder(indice_da_resposta):
	for botao in botoes:
		botao.disabled = true

	var pergunta_data = perguntas[pergunta_atual]
	var resposta_do_jogador = botoes[indice_da_resposta].text
	var texto_resposta_certa = pergunta_data[resposta_correta + 1]
	
	gabarito.append({
		"pergunta": pergunta_data[0], 
		"resposta_jogador": resposta_do_jogador, 
		"resposta_certa": texto_resposta_certa
	})
	
	if indice_da_resposta == resposta_correta:
		boss_health -= 10
		boss_health_bar.value = boss_health
		player_sprite.play("Apontando")
	else:
		player_health -= 10
		player_health_bar.value = player_health
		player_sprite.play("Parado")

	await get_tree().create_timer(1.5).timeout
	
	if player_health <= 0 or boss_health <= 0:
		mostrar_resumo()
	else:
		pergunta_atual += 1
		mostrar_pergunta()

func mostrar_resumo():
	pergunta_label.visible = false
	for botao in botoes:
		botao.visible = false
	
	resumo_label.visible = true
	botao_proximo.visible = true
	botao_anterior.visible = true
	botao_menu.visible = true
	
	indice_gabarito = 0
	atualizar_gabarito_na_tela()

func atualizar_gabarito_na_tela():
	var item = gabarito[indice_gabarito]
	resumo_label.bbcode_enabled = true
	resumo_label.text = "[center][color=yellow]Pergunta:[/color] %s\n[color=green]Sua resposta:[/color] %s\n[color=red]Resposta correta:[/color] %s\n\nPergunta %d de %d[/center]" % [
		item["pergunta"],
		item["resposta_jogador"],
		item["resposta_certa"],
		indice_gabarito + 1,
		gabarito.size()
	]
	
	botao_anterior.disabled = (indice_gabarito == 0)
	botao_proximo.disabled = (indice_gabarito == gabarito.size() - 1)

func _on_alternativa1_button_pressed():
	responder(0)

func _on_alternativa2_button_2_pressed():
	responder(1)

func _on_alternativa3_button_3_pressed():
	responder(2)

func _on_alternativa4_button_4_pressed():
	responder(3)

func _on_proximo_pressed():
	if indice_gabarito < gabarito.size() - 1:
		indice_gabarito += 1
		atualizar_gabarito_na_tela()

func _on_anterior_pressed():
	if indice_gabarito > 0:
		indice_gabarito -= 1
		atualizar_gabarito_na_tela()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Cenas/Menu Principal.tscn")
