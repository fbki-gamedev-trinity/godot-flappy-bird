extends Area2D

signal hit #столкновение
signal scored # проход через трубы

func _on_body_entered(body):
	hit.emit()

func _on_score_area_body_entered(body):
	scored.emit()
