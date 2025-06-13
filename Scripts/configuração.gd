extends Control

@onready var option_button = $VBoxContainer/OptionButton
@onready var salvar_button = $VBoxContainer/Button

var temas_perguntas = {
	"perguntas.txt": "Conjuntos",
	"Funcao.txt": "Funções",
	"Relacao.txt": "Relações",
	"Sequenciasnum.txt": "Sequências Numéricas"
}

func _ready():
	_preencher_opcoes()
	salvar_button.pressed.connect(_on_salvar_button_pressed)

func _preencher_opcoes():
	option_button.clear()
	for nome_arquivo in temas_perguntas:
		var nome_amigavel = temas_perguntas[nome_arquivo]
		option_button.add_item(nome_amigavel)
		
		var index = option_button.get_item_count() - 1
		option_button.set_item_metadata(index, nome_arquivo)

func _on_salvar_button_pressed():
	var indice_selecionado = option_button.get_selected_id()
	var arquivo_selecionado = option_button.get_item_metadata(indice_selecionado)
	
	var config = ConfigFile.new()
	config.set_value("Jogo", "arquivo_perguntas", arquivo_selecionado)
	config.save("user://config.cfg")
	
	get_tree().change_scene_to_file("res://Cenas/Menu Principal.tscn")
