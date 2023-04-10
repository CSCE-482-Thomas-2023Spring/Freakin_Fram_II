# 1 and 3 can be on to power Room A, but not both
# 2 must be off because there's a bad wire in room B
# 4 and 5 must be on for the reactor to be safe
# 6 and 7 can be on or off
switch_1 = False
switch_2 = False
switch_3 = False
switch_4 = False
switch_5 = False
switch_6 = False
switch_7 = False
print(((switch_1 or switch_3) and (not switch_1 or not switch_3)) and not switch_2 and switch_4 and switch_5)
