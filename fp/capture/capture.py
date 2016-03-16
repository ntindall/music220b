from subprocess import call

#call(["tshark", "-i", "en1", "-p", "-f", "ip"])
call(["tshark", "-i", "en1", "-p"])