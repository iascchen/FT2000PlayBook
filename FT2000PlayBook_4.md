# FT2000/4 & Kylin V10 Desktop 玩耍记录(4) —— Kubernetes 使用

## Arm64v8 的 Docker Image

[https://hub.docker.com/u/arm64v8/](https://hub.docker.com/u/arm64v8/) 有很多 Arm64V8 的 Docker Image。可以参考使用。

MySQL 仅有版本 8 支持 Arm64。

    docker pull mysql/mysql-server
    
## 使用 Dashboard

dashboard 相关项目地址在： [https://github.com/kubernetes/dashboard](https://github.com/kubernetes/dashboard)。

官方文档中建议的使用方式如下：

	$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml

dashboard的yaml文件已经在git下来的仓库中。执行：

	$ cd yaml/dashboard
	$ kubectl apply -f kubernetes-dashboard.yaml

	$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml

查看状态：

	$ kubectl get pod -n kubernetes-dashboard
	NAME                                        READY   STATUS    RESTARTS   AGE
	dashboard-metrics-scraper-64c564578-jjkmp   1/1     Running   0          16s
	kubernetes-dashboard-6f8484b5b-xwfbn        1/1     Running   0          16s


配置控制台访问令牌

	TOKEN=$(kubectl -n kube-system describe secret default| awk '$1=="token:"{print $2}')
	kubectl config set-credentials docker-for-desktop --token="${TOKEN}"
	echo $TOKEN

开启 API Server 访问代理

	$ kubectl proxy

通过如下 URL 访问 Kubernetes dashboard

[http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

登录dashboard的时候, 选择 令牌。并输入上文控制台输出的 Token 内容。

或者选择 Kubeconfig 文件, 路径如下：`$HOME/.kube/config`

修改 yaml

登陆进去之后，发现获取不到数据，报错信息如下：

	serviceaccounts is forbidden: User "system:serviceaccount:kube-system:default" cannot list resource "serviceaccounts" in API group "" in the namespace "default"
	configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list resource "configmaps" in API group "" in the namespace "default"
	...

需要修改 kubernetes-dashboard.yaml 增加以下信息。


	---

	apiVersion: v1
	kind: ServiceAccount
	metadata:
	name: aks-dashboard-admin
	namespace: kube-system

	---

	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRoleBinding
	metadata:
	name: aks-dashboard-admin
	roleRef:
	apiGroup: rbac.authorization.k8s.io
	kind: ClusterRole
	name: cluster-admin
	subjects:
	- kind: ServiceAccount
	name: aks-dashboard-admin
	namespace: kube-system

	---

	apiVersion: rbac.authorization.k8s.io/v1beta1
	kind: ClusterRoleBinding
	metadata:
	name: kubernetes-dashboard
	labels:
		k8s-app: kubernetes-dashboard
	roleRef:
	apiGroup: rbac.authorization.k8s.io
	kind: ClusterRole
	name: cluster-admin
	subjects:
	- kind: ServiceAccount
	name: kubernetes-dashboard
	namespace: kube-system

	---

	apiVersion: rbac.authorization.k8s.io/v1beta1
	kind: ClusterRoleBinding
	metadata:
	name: kubernetes-dashboard-head
	labels:
		k8s-app: kubernetes-dashboard-head
	roleRef:
	apiGroup: rbac.authorization.k8s.io
	kind: ClusterRole
	name: cluster-admin
	subjects:
	- kind: ServiceAccount
	name: kubernetes-dashboard-head
	namespace: kube-system

### Clean up

	如果需要删除此部署，可以采用以下命令

	$ kubectl delete -f kubernetes-dashboard_arm64.yaml

## 使用 Stateful Server 测试

参考链接 [https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/) 

下载 yaml 文件。

	wget https://kubernetes.io/examples/application/wordpress/mysql-deployment.yaml
	wget https://kubernetes.io/examples/application/wordpress/wordpress-deployment.yaml
	
对它们做修改，将 docker image 设置为 Arm64 的版本。

	$ cd stateful
	$ cat <<EOF >./kustomization.yaml
	secretGenerator:
	- name: mysql-pass
	  literals:
	  - password=MY_PASSWORD
	resources:
	  - mysql-deployment_arm64.yaml
	  - wordpress-deployment_arm64.yaml
	EOF

### Apply and Verify

	$ kubectl apply -k ./
		
	kubectl get secrets
	kubectl get pvc
	kubectl get pods
	
	kubectl get services wordpress

运行这个命令来获取服务。

	kubectl port-forward svc/wordpress 8080:80

然后打开 [http://localhost:8080/](http://localhost:8080/)

查看数据库，然后打开你的客户端应用。

	kubectl port-forward svc/wordpress-mysql 3306:3306

### Clean up

	kubectl delete -k ./

## 使用 Stateless Server 测试

	wget https://k8s.io/examples/service/load-balancer-example.yaml

	
	
### Apply and Verify	

	kubectl apply -f load-balancer_arm64.yaml
		
	kubectl get deployments hello-world
 	kubectl describe deployments hello-world
 
	kubectl get replicasets
	kubectl describe replicasets
	
暴露访问服务	
	
	kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
	
	kubectl get services my-service
	kubectl describe services my-service
	
	kubectl get pods --output=wide
	
	kubectl get svc my-service

访问 [http://localhost:8080/](http://localhost:8080/)
	
### Clean up

	kubectl delete services my-service
	kubectl delete deployment hello-world
	
	kubectl delete -f load-balancer_arm64.yaml