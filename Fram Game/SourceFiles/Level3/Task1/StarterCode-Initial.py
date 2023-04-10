from functions import *
def takeAction(distance_to_asteroid, size_of_asteroid):
	if distance_to_asteroid >= 2: # 200
		log_asteroid()
	elif distance_to_asteroid >= 1: # 100
		ping_asteroid()
		log_asteroid()
	else:
		if size_of_asteroid >= 100: # 5
			blast_it()
		else:
			take_evasive_move(size_of_asteroid)
			course_correct(size_of_asteroid)