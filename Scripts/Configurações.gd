# =========================================================================
# SCRIPT: Configuracao.gd
# FUNÇÃO: Gerencia a tela de configurações, permitindo ao jogador
#         escolher o tema das perguntas e salvando essa escolha.
# =========================================================================
extends Control

# --- Variáveis de Referência aos Nós ---
# Atalhos para os nós da cena que vamos manipular. @onready garante
# que o Godot só vai pegar a referência quando a cena estiver pronta.
@onready var option_button = $"Caixa Configuracao -VBoxContainer/OptionButton"
@onready var salvar_button = $"Caixa Configuracao -VBoxContainer/Salvar"

# --- Variáveis de Lógica ---
# Dicionário que conecta o nome do arquivo de perguntas (a chave)
# com o nome amigável que será exibido para o jogador (o valor).
var arquivos_perguntas = {
	"perguntas.txt": "Conjuntos",
	"Funcao.txt": "Funções",
	"Relacao.txt": "Relações",
	"Sequenciasnum.txt": "Sequências numéricas"
}
var arquivo_selecionado = "perguntas.txt" # Valor padrão

# -------------------------------------------------------------------------
# FUNÇÕES DO GODOT
# -------------------------------------------------------------------------

# A função _ready() é chamada automaticamente pelo Godot uma única vez,
# assim que a cena e todos os seus nós filhos entram na árvore de cenas.
func _ready():
	# Popula o menu suspenso com os temas disponíveis.
	for nome_legivel in arquivos_perguntas.values():
		option_button.add_item(nome_legivel)
	
	# Deixa a primeira opção selecionada por padrão.
	option_button.select(0)

	# Conecta o sinal 'pressed' (clique) do botão de salvar à nossa função.
	salvar_button.pressed.connect(_on_salvar_button_pressed)

# -------------------------------------------------------------------------
# FUNÇÕES CONECTADAS A SINAIS (Callbacks)
# -------------------------------------------------------------------------

# Esta função é executada quando o botão 'salvar_button' é pressionado.
func _on_salvar_button_pressed():
	# Pega o índice da opção que o jogador selecionou no menu suspenso.
	var indice_selecionado = option_button.get_selected()
	# Usa o índice para pegar o texto da opção (o nome amigável).
	var nome_legivel = option_button.get_item_text(indice_selecionado)
	# Procura no nosso dicionário qual nome de arquivo corresponde ao nome amigável.
	arquivo_selecionado = arquivos_perguntas.keys()[arquivos_perguntas.values().find(nome_legivel)]
	
	# Cria um novo objeto para gerenciar o arquivo de configuração.
	var config = ConfigFile.new()
	# Define o valor no arquivo: na seção [Jogo], a chave 'arquivo_perguntas' terá o valor que selecionamos.
	config.set_value("Jogo", "arquivo_perguntas", arquivo_selecionado)
	# Salva o arquivo no diretório 'user://', que é uma pasta segura no computador do jogador.
	config.save("user://config.cfg")
	
	print("Arquivo de perguntas selecionado: " + arquivo_selecionado)

# Esta função é executada quando o botão (que agora foi removido, mas estava no código) é pressionado.
func _on_salvar_pressed() -> void:
	# Retorna para a cena do Menu Principal.
	get_tree().change_scene_to_file("res://Cenas/MenuPrincipal.tscn")
