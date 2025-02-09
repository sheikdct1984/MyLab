           ******#Master  Worker Nodes****
#Root user access**
sudo su

**#setting K8s Cluster version**
export k8s_version="v1.29"
echo $k8s_version 
#Creating Kube config folder
mkdir -p $HOME/.kube
#Update the system's package list and install necessary dependencies 
sudo apt-get update
sudo apt install apt-transport-https curl -y

## Install containerd
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io -y
## Create containerd configuration
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
## Edit /etc/containerd/config.toml
sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
#Restart containerd:
sudo systemctl restart containerd
## Install Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/$k8s_version/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/'"$k8s_version"'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
## Disable swap
sudo swapoff -a
## Enable kernel modules
sudo modprobe br_netfilter
# Add some settings to sysctl
sudo sysctl -w net.ipv4.ip_forward=1
 
#Master Node only

## Initialize the Cluster (Run only on master)

sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config


## Install Flannel (Run only on master)

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

## Verify Installation

kubectl get pods --all-namespaces
