from fabric import Connection, SerialGroup
from subprocess import check_output
from json import loads
from sys import exit
from time import sleep

data = loads(check_output(["terraform","output","-json"]))

masters = data["master_ips"]["value"]
master0 = masters.pop()

print("Initializing cluster on first node ({})".format(master0))

with Connection(master0) as c:
    r = c.sudo("kubeadm init --control-plane-endpoint {proxy_ip[value]}:6443 --pod-network-cidr=10.244.0.0/16 --upload-certs".format(**data)).stdout.split("\n")
    master_join_command = r[r.index("You can now join any number of the control-plane node running the following command on each as root:")+2]
    worker_join_command = r[r.index("Then you can join any number of worker nodes by running the following on each as root:")+2]
    c.sudo('chmod a+r /etc/kubernetes/admin.conf')
    c.get('/etc/kubernetes/admin.conf')
    print('if you want to use kubectl locally, run\n    export KUBECONFIG=$(pwd)/admin.conf')

print("Joining the other nodes to the control plane")
sleep(20)

with SerialGroup(*data["master_ips"]["value"]) as c:
    c.run("sudo "+master_join_command)
