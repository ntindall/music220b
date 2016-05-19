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

fn = "capture.txt"

def tail_forever(fn):
    p = subprocess.Popen(["tail", "-F", fn], stdout=subprocess.PIPE)
    while 1:
        line = p.stdout.readline()
        tailq.put(line)
        if not line:
            break

t = threading.Thread(target=tail_forever, args=(fn,))
t.daemon = True
t.start()

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

  str = str.decode("utf-8")
  #print (str)
  elements = str.split()

  from_ipv4 = elements[2].split('.')
  to_ipv4   = elements[4].split('.')

  try: 
    msg.add_arg(int(from_ipv4[0]))
    msg.add_arg(int(from_ipv4[1]))
    msg.add_arg(int(from_ipv4[2]))
    msg.add_arg(int(from_ipv4[3]))


    msg.add_arg(int(to_ipv4[0]))
    msg.add_arg(int(to_ipv4[1]))
    msg.add_arg(int(to_ipv4[2]))
    msg.add_arg(int(to_ipv4[3]))
  except:
    continue;

  msg = msg.build()
  client.send(msg)