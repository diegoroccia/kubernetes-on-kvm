from fabric import Connection, SerialGroup
from subprocess import check_output
from json import loads
from sys import exit
from time import sleep

data = loads(check_output(["terraform","output","-json"]))

master = data["master_ip"]["value"]

print("Initializing cluster on first node ({})".format(master))

with Connection(master) as c:
    #r = c.sudo("kubeadm init --control-plane-endpoint {proxy_ip[value]}:6443 --pod-network-cidr=10.244.0.0/16 --upload-certs".format(**data)).stdout.split("\n")
    r = c.sudo("kubeadm init --pod-network-cidr=10.244.0.0/16".format(**data)).stdout.split("\n")
    #m = r.index("You can now join any number of the control-plane node running the following command on each as root:")+2
    w = r.index("Then you can join any number of worker nodes by running the following on each as root:")+2
    #master_join_command = ''.join(r[m:m+2])
    worker_join_command = ''.join(r[w:w+2])
    c.sudo('chmod a+r /etc/kubernetes/admin.conf')
    c.get('/etc/kubernetes/admin.conf')
    print('if you want to use kubectl locally, run\n    export KUBECONFIG=$(pwd)/admin.conf')

sleep(20)

with Connection(data["worker_ip"]["value"]) as c:
    c.sudo(worker_join_command)
