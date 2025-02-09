## Master & Worker Nodes Steps

### Root user access
```sh
sudo su
```

### Setting K8s Cluster version
```sh
export k8s_version="v1.29"
echo $k8s_version
```

### Creating Kube config folder
```sh
mkdir -p $HOME/.kube
```

### Update the system's package list and install necessary dependencies
```sh
sudo apt-get update
sudo apt install apt-transport-https curl -y
```

### Install containerd
```sh
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io -y
```

### Create containerd configuration
```sh
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

### Edit /etc/containerd/config.toml
```sh
sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
```

### Restart containerd
```sh
sudo systemctl restart containerd
```

### Install Kubernetes
```sh
curl -fsSL https://pkgs.k8s.io/core:/stable:/$k8s_version/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/'"$k8s_version"'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
```

### Disable swap
```sh
sudo swapoff -a
```

### Enable kernel modules
```sh
sudo modprobe br_netfilter
```

### Add some settings to sysctl
```sh
sudo sysctl -w net.ipv4.ip_forward=1
```

## Master Node only

### Initialize the Cluster (Run only on master)
```sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
exit
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install Flannel (Run only on master)
```sh
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Verify Installation
```sh
alias k=kubectl
k get pods --all-namespaces
k get no
```
## Worker Node only

```sh
kubeadm join xxxxxx:6443 --token xxxxxxxxx \
    --discovery-token-ca-cert-hash xxxxxxxxxxxxxxx

vi $HOME/.kube/config   # Copy the contents of this file from master node
sudo chown $(id -u):$(id -g) $HOME/.kube/config
alias k=kubectl
k get node
k get pods --all-namespaces
```

## Master Node: (Normal user account)

### View Kube config
```sh
cat $HOME/.kube/config
```

### List SSH keys
```sh
ls ~/.ssh/
```

### Generate SSH key
```sh
ssh-keygen -t rsa -b 4096 -C "azureuser"
```

### List SSH keys again
```sh
ls ~/.ssh/
```

### View public SSH key and copy thr contents 
```sh
cat ~/.ssh/id_rsa.pub
```

## Worker 1: (Normal user account)

### Create Kube config directory
```sh
mkdir -p $HOME/.kube
```

### Edit authorized keys and paste the copied contents from master node
```sh
vim ~/.ssh/authorized_keys
```


## Back to Master Node:

### Copy Kube config to Worker 1
```sh
scp $HOME/.kube/config azureuser@10.0.1.4:$HOME/.kube/config
```

## Back to Worker 1:

### Change ownership of Kube config
```sh
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Set kubectl alias and verify nodes and pods
```sh
alias k=kubectl
k get node
k get pod
```

## Worker 2: (Normal user account)

### Create Kube config directory
```sh
mkdir -p $HOME/.kube
```

### Edit authorized keys and paste the copied contents from master node
```sh
vim ~/.ssh/authorized_keys
```



## Back to Master Node:

### Copy Kube config to Worker 2
```sh
scp $HOME/.kube/config azureuser@10.0.1.5:$HOME/.kube/config
```

## Back to Worker 2:

### Change ownership of Kube config
```sh
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Set kubectl alias and verify nodes and pods
```sh
alias k=kubectl
k get node
k get pod
```

