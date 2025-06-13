extends Control


func _on_iniciar_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Jogo.tscn")


func _on_config_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Configuração.tscn")


func _on_sair_button_3_pressed() -> void:
	get_tree().quit()
