from fabric import Connection, SerialGroup
from subprocess import check_output
from json import loads
from sys import exit
from time import sleep

data = loads(check_output(["terraform","output","-json"]))

master = data["master_ip"]["value"]

print("Initializing cluster on first node ({})".format(master))

with Connection(master) as c:
    worker_join_command = c.sudo("kubeadm token create --print-join-command", hide=True).stdout

print("Joining Workers")
with Connection(data["worker_ip"]["value"]) as c:
    c.sudo(worker_join_command)
