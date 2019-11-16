from fabric import Connection, SerialGroup
from subprocess import check_output
from json import loads
from sys import exit
from time import sleep

data = loads(check_output(["terraform","output","-json"]))

master = data["master_ip"]["value"]

print("Initializing cluster on first node ({})".format(master))

with Connection(master) as c:
    ##r = c.sudo("kubeadm init --control-plane-endpoint {proxy_ip[value]}:6443 --pod-network-cidr=10.244.0.0/16 --upload-certs".format(**data)).stdout.split("\n")
    c.sudo("kubeadm init --pod-network-cidr=10.244.0.0/16".format(**data), hide=True)
    c.sudo('chmod a+r /etc/kubernetes/admin.conf')
    c.get('/etc/kubernetes/admin.conf')
    print('if you want to use kubectl locally, run\n    export KUBECONFIG=$(pwd)/admin.conf')
    c.put('manifests/calico.yaml','/tmp')
    c.run("KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /tmp/calico.yaml")
    worker_join_command = c.sudo("kubeadm token create --print-join-command", hide=True).stdout
    print('Waiting 20 seconds')

sleep(20)

print("Joining Workers")
with Connection(data["worker_ip"]["value"]) as c:
    c.sudo(worker_join_command)
