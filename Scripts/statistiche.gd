extends Control

@onready var inactive_clients_control: Control = %InactiveClients

func _ready():
	# Clienti che non vengono da più di 30 giorni
	inactive_clients_control.get_node("Button").pressed.connect(func():
		inactive_clients_control.get_node("Clienti").visible = not inactive_clients_control.get_node("Clienti").visible
	)
	var clienti_inattivi = get_inactive_clients(30)
	for cliente in clienti_inattivi:
		var label = Label.new()
		label.text = cliente.nominativo
		inactive_clients_control.get_node("Clienti").add_child(label)

func get_inactive_clients(days_threshold: int) -> Array[Cliente]:
	var today = Date.today()
	var threshold_date = today.add_days(-days_threshold)
	var client_last_visits: Dictionary = {}
	var inactive_clients: Array[Cliente] = []
	
	# Find the most recent visit for each client
	for trattamento: Trattamento in TreatManagerNode.log_trattamenti:
		if trattamento and trattamento.cliente and trattamento.data:
			var cliente = trattamento.cliente
			if not client_last_visits.has(cliente) or TreatManagerNode.is_later(trattamento.data, client_last_visits[cliente]):
				client_last_visits[cliente] = trattamento.data
	
	# Check which clients haven't visited within the threshold
	for cliente in ClientManagerNode.clienti:
		if client_last_visits.has(cliente):
			var last_visit: Date = client_last_visits[cliente]
			# If the last visit is before the threshold date, they're inactive
			if last_visit.is_before(threshold_date):
				inactive_clients.append(cliente)
		else:
			# Client has never had any treatments
			inactive_clients.append(cliente)
	
	return inactive_clients
