from subprocess import call

while (True):
  call(["traceroute", "google.com"])
  call(["traceroute", "denmark.de"])
 # call(["traceroute", "baidu.com"])
