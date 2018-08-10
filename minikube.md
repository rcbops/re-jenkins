# Minikube

Minikube is a tool that makes it easy to run Kubernetes locally. It provides a light-weight local Kubernetes
installation for day-to-day development and learning exploration. Minikube runs a single-node Kubernetes cluster inside
a VM on your laptop for users looking to try out Kubernetes or develop with it day-to-day.  Local installations leverage
VirtualBox as a local virtualization solution.

Download a release: https://github.com/kubernetes/minikube/releases

To install, just download the binary, make it executable, and move somewhere that would be in your path:

For MacOS X `brew` users:
```bash
brew cask install minikube
```

Also for Mac, you may want to leverage the `xhyve` drive (although now it states that it's now deprecated).  Installation goes something like this:

```bash
brew install docker-machine-driver-xhyve
# then set the appropriate perms:
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

Or just download the latest (MacOS X example):

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.28.0/minikube-darwin-amd64 && \
  chmod +x minikube && \
  sudo mv minikube /usr/local/bin/

# Make sure minikube is in your shell path - it would be odd if it wasn't already
export PATH=$PATH:/usr/local/bin
```

## Minikube Usage

Minikube packages and configures a Linux VM, the container runtime, and all Kubernetes components, optimized for local development.

Minikube supports Kubernetes features such as:

- DNS
- NodePorts
- ConfigMaps and Secrets
- Dashboards
- Container Runtime: Docker, and rkt
- Enabling CNI (Container Network Interface)

Plus, there are a few other requirements:

- OS X
  - xhyve driver, VirtualBox or VMware Fusion installation
- Linux
  - VirtualBox or KVM installation
- VT-x/AMD-v virtualization must be enabled in BIOS
- `kubectl` must be on your path. Minikube currently supports any version of `kubectl` greater than 1.0, but we
  recommend using the most recent version. You can install `kubectl` with these steps. Hyper-v users may need to create
  a new external network switch as described here. This step may prevent a problem in which minikube start hangs
  indefinitely, unable to ssh into the minikube virtual machine. In this add, add the
  `--hyperv-virtual-switch=switch-name` argument to the minikube start command.

Reference: https://github.com/kubernetes/minikube/blob/v0.19.0/README.md

## Minikube Start

The `minikube start` command can be used to start your cluster. This command creates and configures a virtual machine
that runs a single-node Kubernetes cluster. This command also configures your `kubectl` installation to communicate with
this cluster.  It's sometimes helpful to adjust the amount of CPU (`--cpus`) and Memory (`--memory`) allocated to the
base VM.

Note that on OS X we recommend you use the `xhyve` driver which avoids you having to install VirtualBox and Vagrant; its
also leaner & meaner and requires less memory (ref: https://fabric8.io/guide/getStarted/minikube.html):

```bash
minikube start --memory=4000 --cpus 4
# or
minikube start --memory=6000 --vm-driver=xhyve
# or
minikube start --cpus 2 --memory 5144 --vm-driver=virtualbox
```

Other examples:

```bash
minikube start --cpus 8 --memory 12000
Starting local Kubernetes cluster...
Downloading Minikube ISO
 36.00 MB / 36.00 MB [==============================================] 100.00% 0s
Kubectl is now configured to use the cluster.

# Configuration file
ls ~/.kube/
./      ../     config

cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/deald/.minikube/ca.crt
    server: https://192.168.99.101:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/deald/.minikube/apiserver.crt
    client-key: /Users/deald/.minikube/apiserver.key


kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
deployment "hello-minikube" created

kubectl expose deployment hello-minikube --type=NodePort
# note: on my mac I had to do:
# kubectl --namespace rpc-re \
  expose deployment hello-minikube \
  --type=NodePort \
  --external-ip=192.168.99.100 \
  --port=8080 \
  --target-port=8080

service "hello-minikube" exposed

kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
hello-minikube-3015430129-991h1   1/1       Running   0          2m

minikube service hello-minikube --url
http://192.168.99.101:32194

curl $(minikube service hello-minikube --url)
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.99.101:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.99.101:32194
user-agent=curl/7.43.0
BODY:
-no body in request-

kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
hello-minikube-3015430129-991h1   1/1       Running   0          4m
```

## Minikube Stop

The `minikube stop` command can be used to stop your cluster. This command shuts down the `minikube` virtual machine,
but preserves all cluster state and data. Starting the cluster again will restore it to it's previous state.

```bash
minikube stop
Stopping local Kubernetes cluster...
Machine stopped.
```

> Note: after starting and restarting, I received the following error: _error: You must be logged in to the server (the
  server has asked for the client to provide credentials)_ By running the following command, I was able to get the pod
  status.

The current workaround there is to run (cluster may need time to be fully up first):

```bash
kubectl edit secret $(kubectl get secrets --namespace=kube-system -o jsonpath='{.items[0].metadata.name}') --namespace=kube-system
```

Which will open up your editor. Delete the line that starts with: token:, save the file and exit.

## Minikube Delete

The `minikube delete` command can be used to delete your cluster. This command shuts down and deletes the `minikube`
virtual machine. No data or state is preserved.

```bash
minikube delete
Deleting local Kubernetes cluster...
Machine deleted.
```

## Minikube Dashboard

To access the Kubernetes Dashboard, run this command in a shell after starting minikube to get the address:

```bash
minikube dashboard
Opening kubernetes dashboard in default browser...
```

## Minikube Services

Services

To access a service exposed via a node port, run this command in a shell after starting Minikube to get the address:

```bash
# Usage
minikube service [-n NAMESPACE] [--url] NAME

# For example:
$ minikube service hello-minikube --url
http://192.168.99.102:30051
```

## RPC-RE Jenkins Specific Notes

In order to view the service endpoint outside of the Minikube environment, you need to take the extra step to get the
Minikube URL for the service. This doesn't apply for normal kubernetes deployments.

TODO: test this
```bash
minikube --namespace rpc-re service jenkins-master --url
```
