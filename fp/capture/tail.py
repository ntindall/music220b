#https://stackoverflow.com/questions/12523044/how-can-i-tail-a-log-file-in-python

#TAIL RELATED 
import threading, queue, subprocess

#OSC RELATED
import argparse
import random
import time

from pythonosc import osc_message_builder
from pythonosc import udp_client

#TAIL LOGIC

tailq = queue.Queue(maxsize=10) # buffer at most 100 lines

fn = "output.txt"

def tail_forever(fn):
    p = subprocess.Popen(["tail", "-F", fn], stdout=subprocess.PIPE)
    while 1:
        line = p.stdout.readline()
        tailq.put(line)
        if not line:
            break

threading.Thread(target=tail_forever, args=(fn,)).start()

# f = open ('tail.txt', 'a')
# while True:
#   f.write( tailq.get())
#   f.seek(0) # blocks
#   f.flush()

# f.close()



client = udp_client.UDPClient("127.0.0.1", 6449)

while True:
  str = tailq.get()
  msg = osc_message_builder.OscMessageBuilder(address = "/data")
  msg.add_arg(str.decode("utf-8") )
  msg = msg.build()
  client.send(msg)
  print (str)
  time.sleep(1)