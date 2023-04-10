# During the system damage, the collison avoidance settings of the ship was changed
# Fix the settings based off these instructions
def takeAction(distance_to_asteriod, size_of_asteriod):
    if distance_to_asteroid >= 2:
        log_asteriod()
    elif distance_to_asteroid >= 1:
        ping_asteriod()
        log_asteriod()
    else:
        if size_of_asteriod >= 100:
            blast_it()
        else:
            take_evasive_move(size_of_asteriod)
            course_correct(size_of_asteriod)