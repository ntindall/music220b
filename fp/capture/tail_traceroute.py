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



client = udp_client.UDPClient("127.0.0.1", 6471)

while True:
  str = tailq.get()
  msg = osc_message_builder.OscMessageBuilder(address = "/data")

  str = str.decode("utf-8")
  print (str)
  elements = str.split()
  #print (elements)

  try: 
    node_ipv4 = elements[2].split('.');
    RTT = (float(elements[3]) + float(elements[5]) + float(elements[7])) / 3

    msg.add_arg(RTT)

    msg.add_arg(int(node_ipv4[0][1:]))
    msg.add_arg(int(node_ipv4[1]))
    msg.add_arg(int(node_ipv4[2]))
    msg.add_arg(int(node_ipv4[3][:1]))

  except:
    continue;

  msg = msg.build()
  client.send(msg)