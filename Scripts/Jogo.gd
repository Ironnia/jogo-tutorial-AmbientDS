# =========================================================================
# SCRIPT: Jogo.gd
# FUNÇÃO: Controla toda a lógica da cena principal do jogo, incluindo
#         o quiz, as animações, a vida dos personagens e a tela de resumo.
# =========================================================================
extends Control

# --- Variáveis de Estado do Jogo ---
var perguntas = [] # Armazena todas as perguntas carregadas do arquivo.
var pergunta_atual = 0 # Índice da pergunta que está sendo exibida.
var resposta_correta = -1 # Índice da alternativa correta para a pergunta atual.
var respostas_corretas = 0 # Contador de acertos.
var respostas_erradas = 0 # Contador de erros.
var gabarito = [] # Salva o histórico de respostas para o resumo final.
var indice_gabarito = 0 # Controla qual item do gabarito está sendo exibido.

# --- Variáveis de Vida ---
var player_health = 100
var boss_health = 100

# --- Referências aos Nós da Cena ---
@onready var pergunta_label = $"Mostrar texto"
@onready var botoes = [
	$VBoxContainer/GridContainer/Button,
	$VBoxContainer/GridContainer/Button2,
	$VBoxContainer/GridContainer/Button3,
	$VBoxContainer/GridContainer/Button4
]
@onready var resumo_label = $ResumoLabel
@onready var botao_proximo = $BotaoProximo
@onready var botao_anterior = $BotaoAnterior
@onready var player_health_bar = $CanvasLayer/PlayerHealthBar
@onready var boss_health_bar = $CanvasLayer/BossHealthBar
@onready var player_sprite = $"AnimatedSprite2D2-Phoenix"
@onready var boss_sprite = $"AnimatedSprite2D-Manfred"
@onready var botao_menu = $"Menu Principal"

# --- Referências aos Nós de Áudio ---
@onready var musica_fundo = $"Musica de fundo"
@onready var som_acertou = $Acertou
@onready var som_errou = $Errou

# --- Preload de Recursos ---
# Carrega os arquivos de música na memória antes do jogo começar,
# para evitar engasgos durante a troca de faixas.
@onready var musica_1 = preload("res://Sons/(Tela Jogo) 1-04 Cross-Examination - Moderato 2001.mp3")
@onready var musica_2 = preload("res://Sons/(Tela Jogo, Jogador MORRENDO)1-07 Cross-Examination - Allegro 2001.mp3")
@onready var musica_ganhou = preload("res://Sons/(Tela Jogo, Jogador GANHOU) 1-25 Victory! - Our First Win.mp3")
@onready var musica_perdeu = preload("res://Sons/(Tela Jogo, Jogador PERDEU)1-22 Reminiscences - The DL-6 Incident.mp3")


func _ready():
	# Inicializa o jogo.
	carregar_perguntas()
	mostrar_pergunta()
	# Esconde os elementos da tela de resumo.
	resumo_label.visible = false
	botao_proximo.visible = false
	botao_anterior.visible = false
	botao_menu.visible = false
	# Configura as barras de vida.
	player_health_bar.value = player_health
	boss_health_bar.value = boss_health
	# Inicia as animações padrão.
	player_sprite.play("Idle-Phoenix")
	boss_sprite.play("Idle-Manfred")
	# Inicia a música de fundo.
	musica_fundo.stream = musica_1
	musica_fundo.play()

# Carrega as perguntas do arquivo de texto escolhido pelo jogador.
func carregar_perguntas():
	var config = ConfigFile.new()
	var erro = config.load("user://config.cfg")
	var arquivo_perguntas = "perguntas.txt"
	
	if erro == OK:
		arquivo_perguntas = config.get_value("Jogo", "arquivo_perguntas", "perguntas.txt")
	else:
		print("Erro ao carregar arquivo de configuração. Usando perguntas.txt por padrão.")

	var file = FileAccess.open("res://%s" % arquivo_perguntas, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var linha = file.get_line()
			var partes = linha.split("|")
			if partes.size() == 6:
				perguntas.append(partes)
		file.close()
		# Embaralha a ordem das perguntas.
		randomize()
		perguntas.shuffle()
	else:
		print("Erro ao carregar o arquivo de perguntas.")
		pergunta_label.text = "Erro ao carregar perguntas."

# Atualiza a interface com a pergunta atual.
func mostrar_pergunta():
	if pergunta_atual < perguntas.size():
		var pergunta_data = perguntas[pergunta_atual]
		pergunta_label.text = pergunta_data[0]
		resposta_correta = int(pergunta_data[5]) - 1
		
		# Atualiza as animações baseadas na vida atual.
		if player_health <= 40:
			player_sprite.play("Perdendo-Phoenix")
			mudar_musica(musica_2)
		else:
			player_sprite.play("Pensando-Phoenix")

		if boss_health <= 40:
			boss_sprite.play("Perdendo-Manfred")
		else:
			boss_sprite.play("Sorriso-Manfred")
		
		# Preenche os botões com as alternativas.
		for i in range(4):
			botoes[i].text = pergunta_data[i + 1]
			botoes[i].disabled = false
	else:
		# Se não houver mais perguntas, mostra a tela de resumo.
		mostrar_resumo()

# Função principal que processa a resposta do jogador.
func responder_alternativa(indice):
	var pergunta_data = perguntas[pergunta_atual]
	var resposta_jogador = botoes[indice].text
	var resposta_certa_texto = botoes[resposta_correta].text
	
	# Desabilita os botões para evitar múltiplos cliques.
	for botao in botoes:
		botao.disabled = true
	
	if indice == resposta_correta:
		respostas_corretas += 1
		boss_health -= 10
		boss_health_bar.value = boss_health
		player_sprite.play("ACERTEI-Phoenix")
		boss_sprite.play("Nervoso-Manfred")
		som_acertou.play()
		print("Resposta correta!")
	else:
		respostas_erradas += 1
		player_health -= 10
		player_health_bar.value = player_health
		player_sprite.play("NEGAR-Phoenix")
		boss_sprite.play("Errou-Manfred")
		som_errou.play()
		print("Resposta errada.")
	
	# Aguarda a animação de feedback terminar.
	await get_tree().create_timer(1.5).timeout
	
	# Atualiza a animação padrão após o feedback.
	atualizar_animacoes()
	
	# Salva a resposta no gabarito.
	gabarito.append({"pergunta": pergunta_data[0], "resposta_jogador": resposta_jogador, "resposta_certa": resposta_certa_texto})
	
	# Verifica se o jogo terminou.
	if player_health <= 0:
		player_sprite.play("Perdeu-Phoenix")
		boss_sprite.play("Sorriso-Manfred")
		mudar_musica(musica_perdeu)
		mostrar_resumo()
	elif boss_health <= 0:
		player_sprite.play("Ganhou-Phoenix")
		boss_sprite.play("Perdeu-Manfred")
		mudar_musica(musica_ganhou)
		mostrar_resumo()
	else:
		# Se o jogo continua, avança para a próxima pergunta.
		pergunta_atual += 1
		mostrar_pergunta()

# Função auxiliar para trocar a música de fundo.
func mudar_musica(nova_musica):
	if musica_fundo.stream != nova_musica:
		musica_fundo.stop()
		musica_fundo.stream = nova_musica
		musica_fundo.play()

# Função auxiliar para atualizar as animações de idle com base na vida.
func atualizar_animacoes():
	if player_health <= 40:
		player_sprite.play("Perdendo-Phoenix")
	else:
		player_sprite.play("Pensando-Phoenix")

	if boss_health <= 20:
		boss_sprite.play("Perdendo-Manfred")
	else:
		boss_sprite.play("Sorriso-Manfred")

# Conecta os sinais dos botões de alternativa a esta função.
func _on_button_pressed():
	responder_alternativa(0)
func _on_button_2_pressed():
	responder_alternativa(1)
func _on_button_3_pressed():
	responder_alternativa(2)
func _on_button_4_pressed():
	responder_alternativa(3)

# Configura e exibe a tela de resumo final.
func mostrar_resumo():
	if gabarito.size() > 0:
		indice_gabarito = 0
		atualizar_resumo_gabarito()
		resumo_label.visible = true
		botao_proximo.visible = true
		botao_anterior.visible = true
		botao_anterior.disabled = true
		botao_menu.visible = true
	else:
		resumo_label.text = "Sem respostas para mostrar."
	
	pergunta_label.visible = false
	for botao in botoes:
		botao.visible = false

# Atualiza o texto do gabarito na tela.
func atualizar_resumo_gabarito():
	var item = gabarito[indice_gabarito]
	resumo_label.text = "[center][color=yellow]Pergunta:[/color] " + item["pergunta"] + "\n" + "[color=green]Sua resposta:[/color] " + item["resposta_jogador"] + "\n" + "[color=red]Resposta correta:[/color] " + item["resposta_certa"] + "\n" + "Pergunta " + str(indice_gabarito + 1) + " de " + str(gabarito.size()) + "[/center]"

	botao_anterior.disabled = indice_gabarito <= 0
	botao_proximo.disabled = indice_gabarito >= gabarito.size() - 1

# Navegação do gabarito.
func _on_botao_proximo_pressed():
	if indice_gabarito < gabarito.size() - 1:
		indice_gabarito += 1
		atualizar_resumo_gabarito()
func _on_botao_anterior_pressed():
	if indice_gabarito > 0:
		indice_gabarito -= 1
		atualizar_resumo_gabarito()
		
# Voltar ao menu.
func _on_menu_principal_pressed():
	get_tree().change_scene_to_file("res://Cenas/MenuPrincipal.tscn")
