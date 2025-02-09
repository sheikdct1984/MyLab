```bash
cat /etc/os-release | grep -i "NAME"
export k8s_version="v1.30"
echo $k8s_version 
export nodename="master-node"
echo $nodename

echo "##### Before version change######"
cat /etc/apt/sources.list.d/kubernetes.list 

sudo sed -i "s|v1\\.[0-9][0-9]*|${k8s_version}|" /etc/apt/sources.list.d/kubernetes.list

echo "###$$$ after version change ######"
cat /etc/apt/sources.list.d/kubernetes.list 

sudo apt update
sudo apt-cache madison kubeadm  

export kd_version=$(sudo apt-cache madison kubeadm | head -n 1 | awk '{print $3}')
echo $kd_version

export kdv=$(echo $kd_version | cut -d'-' -f1) 
echo $kdv 

sudo apt-mark unhold kubeadm 
sudo apt-get update 
sudo apt-get install -y kubeadm=$kd_version 
sudo apt-mark hold kubeadm
kubeadm version
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v$kdv
kubectl drain $nodename --ignore-daemonsets

sudo apt-mark unhold kubelet kubectl 
sudo apt-get update 
sudo apt-get install -y kubelet=$kd_version kubectl=$kd_version
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl uncordon $nodename
kubectl get nodes
```
