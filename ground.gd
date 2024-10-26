extends Area2D

signal hit #сигнал попадания

func _on_body_entered(body): #обработка столкновения с землёй
	hit.emit() #вызов сигнала
