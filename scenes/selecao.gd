extends Control

func _on_botao_red_pressed():
	Global.personagem = "red"
	get_tree().change_scene_to_file("res://scenes/fase.tscn")

func _on_botao_leaf_pressed():
	Global.personagem = "leaf"
	get_tree().change_scene_to_file("res://scenes/fase.tscn")
