import time
import _pyProm2Json

ITERATIONS = 10000

# Read the "prom-out" file, which contains a sample output from a Prometheus Exporter
# The resulting 'promData' is just a long unicode string
inputFile = open('prom-out', 'r')
promData = "".join(inputFile.readlines())

print("Converting prom-out to JSON, running %s iterations" % ITERATIONS)
startTime = time.time()
for i in range(ITERATIONS):
    # Convert the Prometheus Exporter format to JSON (still in string)
    strJson = _pyProm2Json.prom2json(promData)

elapsedTime = time.time() - startTime
print("Results:")
print("\tElapsed time: %s seconds" % round(elapsedTime, 3))
print("\tAvg. time per call: %s milliseconds" % round(elapsedTime / ITERATIONS * 1000, 3))
