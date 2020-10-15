# FT2000/4 & Kylin V10 Desktop 玩耍记录(4) —— Kubernetes 使用
    
## 使用 Dashboard

dashboard的yaml文件已经在git下来的仓库中，并设定好了使用 Arm64 的容器。执行：

	$ cd yaml/dashboard
	$ kubectl apply -f kubernetes-dashboard.yaml

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

或者选择 Kubeconfig 文件, Mac 路径如下：`$HOME/.kube/config`

	如果需要删除重建，可以采用以下命令

	$ kubectl delete -f kubernetes-dashboard.yaml

## 使用 Stateful Server 测试

参考链接 [https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/) 

下载 yaml 文件。

	wget https://kubernetes.io/examples/application/wordpress/mysql-deployment.yaml
	wget https://kubernetes.io/examples/application/wordpress/wordpress-deployment.yaml
	
对它们做了修改，将 docker image 设置为 Arm64 的版本。

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

	kubectl apply -f load-balancer-example.yaml
		
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
	
	kubectl delete -f load-balancer-example.yaml


