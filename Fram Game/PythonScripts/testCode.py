import json
from types import SimpleNamespace
import sys
import subprocess

# [/home/ethan/.local/share/godot/app_userdata/Fram Game/testCode.py /home/ethan/Documents/repos/Freakin_Fram_II/Fram Game/Puzzle/TestCases/testPuzzle2.json python3 /home/ethan/.local/share/godot/app_userdata/Fram Game/]


test_dir = sys.argv[1]
python_dir = sys.argv[2]
user_dir = sys.argv[3]

player_code = user_dir + "userCode.py"

sys.path.append(user_dir)



text = ''
with open(test_dir, 'r') as file:
    text = file.read()

testData = json.loads(text, object_hook=lambda x: SimpleNamespace(**x))
testCases = testData.cases

results = {"testResults": []}
returnResults = []
stdoutResults = []

importSuccessful = True
try:
    import userCode
except Exception as e:
    results["error"] = f"{e}" # syntax error in userCode usually.
    importSuccessful = False

if importSuccessful:
    for case in testCases:
        returned, stdout = None, None
        returnPassed, stdoutPassed = True, True
        if testData.data.useFunction:
            userSolution = None
            try:
                userSolution = getattr(userCode, testData.data.functionName)
                returned = userSolution(*case.input)
                returnPassed = (not testData.data.useFunction) or (returned == case.returns)
                returnResults.append((returnPassed, returned))
            except Exception as e:
                userSolution = None
            if userSolution is None:
                results["error"] = e.message #"Something went wrong. Check function and parameters"
        else:
            returnResults.append((True, None))

        programOutput = subprocess.run([python_dir, player_code], capture_output=True)
        stdout = programOutput.stdout.decode('utf-8')
        stderr = programOutput.stderr.decode('utf-8')
        stdoutPassed = (not testData.data.usestdout) or (stdout == case.stdout)
        stdoutResults.append((stdoutPassed, returned))
        totalResult = {
            "input": case.input,
            "returns": case.returns,
            "stdout": case.stdout,
            "userReturned": returned,
            "userstdout": stdout,
            "passed": returnPassed and stdoutPassed,
            "stderror": stderr
        }
        results['testResults'].append(totalResult)

resultJSON = json.dumps(results, indent=4)

with open(user_dir + 'results.json', 'w+') as file:
    file.write(resultJSON)

