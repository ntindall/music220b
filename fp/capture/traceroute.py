from subprocess import call

while (True):
  print ("Calling")
  call(["traceroute", "google.com"])
  call(["traceroute", "denmark.de"])
