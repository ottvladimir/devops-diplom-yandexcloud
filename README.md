# Дипломный практикум в Яндекс.Облако
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Подготавливаю облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
```bash
yc iam service-account create terraform
yc iam key create --service-account-name terraform -o terraform.json
yc config set service-account-key terraform.json
export TF_VAR_yc_token=$(yc iam create-token)
SERVICE_ACCOUNT_ID=$(yc iam service-account get --name terraform --format json | jq -r .id)
FOLDER_ID=$(yc iam service-account get --name terraform --format json | jq -r .folder_id)
yc resource-manager folder add-access-binding $FOLDER_ID --role editor --subject 
yc iam service-account add-access-binding $SERVICE_ACCOUNT_ID --role editor 
serviceAccount:$SERVICE_ACCOUNT_ID
```
2. Подготавливаю backend на [Terraform Cloud](https://app.terraform.io/)  
```tf
# backend.tf
terraform {                                                                                                      
  backend "remote" {                                                                                            
    organization = "my_diploma"                                                                                  
    workspaces {                                                                                 
      prefix = "netology-diploma-"                                                                              
    }                                                                                                                     
```
```bash
$ cat ~/.terraformrc
credentials "app.terraform.io" {
token = "Place your token here"
}
```
3. Настраиваю workspaces  
```bash
$ terraform workspace new stage && terraform workspace new prod
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
$ terraform workspace select stage
Switched to workspace "stage".
```
4. Создаю VPC с подсетями в разных зонах доступности.
```tf
# networks.tf
# Create ya.cloud VPC
resource "yandex_vpc_network" "k8s-network" {
  name = "ya-network"
}
# Create ya.cloud public subnet
resource "yandex_vpc_subnet" "k8s-network-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.0.0/24"]
}
resource "yandex_vpc_subnet" "k8s-network-b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.10.0/24"]
}
resource "yandex_vpc_subnet" "k8s-network-c" {
  name           = "public-c"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.28.20.0/24"]
}
```
6. Проверяю команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
```bash
$ terraform apply                                                       
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:                                                                                                                                         
  + create                                                                                                                                                                                                                                                                         

Terraform will perform the following actions:

  # yandex_vpc_network.k8s-network will be created
  + resource "yandex_vpc_network" "k8s-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "ya-network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.k8s-network-a will be created
  + resource "yandex_vpc_subnet" "k8s-network-a" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "172.28.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.k8s-network-b will be created
  + resource "yandex_vpc_subnet" "k8s-network-b" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "172.28.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.k8s-network-c will be created
  + resource "yandex_vpc_subnet" "k8s-network-c" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public-c"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "172.28.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-c"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "stage"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```
```bash
$ terraform destroy 
yandex_vpc_network.k8s-network: Refreshing state... [id=enp7ns968m8iutndnj5p]
yandex_vpc_subnet.k8s-network-b: Refreshing state... [id=e2lsfs5olfd9ugn1q3c5]
yandex_vpc_subnet.k8s-network-c: Refreshing state... [id=b0c001j5je0ja9ab5fi1]
yandex_vpc_subnet.k8s-network-a: Refreshing state... [id=e9bprnucsd5p4i19pkho]
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:                                                                                                                                         
  - destroy
Terraform will perform the following actions:   
                                                
  # yandex_vpc_network.k8s-network will be destroyed            
  - resource "yandex_vpc_network" "k8s-network" {                                                 
      - created_at = "2022-02-08T05:19:36Z" -> null                
      - folder_id  = "b1gbfdm5fn2htkj22u8h" -> null                
      - id         = "enp7ns968m8iutndnj5p" ->  null                                     
      - labels     = {} -> null
      - name       = "ya-network" -> null
      - subnet_ids = [
          - "b0c001j5je0ja9ab5fi1",
          - "e2lsfs5olfd9ugn1q3c5",
          - "e9bprnucsd5p4i19pkho",
        ] -> null
    }

  # yandex_vpc_subnet.k8s-network-a will be destroyed
  - resource "yandex_vpc_subnet" "k8s-network-a" {
      - created_at     = "2022-02-08T05:19:37Z" -> null
      - folder_id      = "b1gbfdm5fn2htkj22u8h" -> null
      - id             = "e9bprnucsd5p4i19pkho" -> null
      - labels         = {} -> null
      - name           = "public-a" -> null
      - network_id     = "enp7ns968m8iutndnj5p" -> null
      - v4_cidr_blocks = [
          - "172.28.0.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-a" -> null
    }

  # yandex_vpc_subnet.k8s-network-b will be destroyed
  - resource "yandex_vpc_subnet" "k8s-network-b" {
      - created_at     = "2022-02-08T05:19:37Z" -> null
      - folder_id      = "b1gbfdm5fn2htkj22u8h" -> null
      - id             = "e2lsfs5olfd9ugn1q3c5" -> null
      - labels         = {} -> null
      - name           = "public-b" -> null
      - network_id     = "enp7ns968m8iutndnj5p" -> null
      - v4_cidr_blocks = [
          - "172.28.10.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-b" -> null
    }

  # yandex_vpc_subnet.k8s-network-c will be destroyed
  - resource "yandex_vpc_subnet" "k8s-network-c" {
      - created_at     = "2022-02-08T05:19:37Z" -> null
      - folder_id      = "b1gbfdm5fn2htkj22u8h" -> null
      - id             = "b0c001j5je0ja9ab5fi1" -> null
      - labels         = {} -> null
      - name           = "public-c" -> null
      - network_id     = "enp7ns968m8iutndnj5p" -> null
      - v4_cidr_blocks = [
          - "172.28.20.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-c" -> null
    }

Plan: 0 to add, 0 to change, 4 to destroy.                                                                                                                         

Do you really want to destroy all resources in workspace "stage"?                                                                                                 
  Terraform will destroy all your managed infrastructure, as shown above.                                                                                         
  There is no undo. Only 'yes' will be accepted to confirm.                                                                                          
  
  Enter a value: yes                                                

yandex_vpc_subnet.k8s-network-a: Destroying... [id=e9bprnucsd5p4i19pkho]                                        
yandex_vpc_subnet.k8s-network-b: Destroying... [id=e2lsfs5olfd9ugn1q3c5]                                        
yandex_vpc_subnet.k8s-network-c: Destroying... [id=b0c001j5je0ja9ab5fi1]                                        
yandex_vpc_subnet.k8s-network-c: Destruction complete after 6s                                                  
yandex_vpc_subnet.k8s-network-a: Destruction complete after 8s                                                  
yandex_vpc_subnet.k8s-network-b: Destruction complete after 9s                                                  
yandex_vpc_network.k8s-network: Destroying... [id=enp7ns968m8iutndnj5p]                                          
yandex_vpc_network.k8s-network: Destruction complete after 1s                                                    
                                                                        
Destroy complete! Resources: 4 destroyed.
```
7. Web-интерфейс Terraform cloud.
[!image](./images/app_terraform_io.png)

---
### Создание Kubernetes кластера
yc managed-kubernetes cluster get-credentials --id catdfo4cstfdivmsvduq --external
На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Подготавливаю inventory.ini
  ```bash
  ./inventory_generator.sh > ../kubespray/inventory/cloud/inventory.ini
  ```
  Стартую kubespray
  ```bash
  ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ../kubespray/inventory/cloud/inventory.ini ../kubespray/cluster.yml -b
  ```
  ```bash
  PLAY RECAP **********************************************************************************************************************************************************
  localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  node-1                     : ok=579  changed=38   unreachable=0    failed=0    skipped=1174 rescued=0    ignored=3   
  node-2                     : ok=526  changed=27   unreachable=0    failed=0    skipped=1046 rescued=0    ignored=2   
  node-3                     : ok=528  changed=28   unreachable=0    failed=0    skipped=1043 rescued=0    ignored=2 
  ```
  Меняю внуиренний ip на внешний.
  Копирую конфиги
  ```
  cp inventory/cloud/artifacts/admin.conf ~/.kube/config
Ожидаемый результат:

Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.
```bash
 kubectl get pods --all-namespacesNAMESPACE     NAME                                      READY   STATUS    RESTARTS      AGEkube-system   calico-kube-controllers-5788f6558-vrdfr   1/1     Running   2 (74m ago)   74mkube-system   calico-node-bz4hv                         1/1     Running   0             75mkube-system   calico-node-dnnps                         1/1     Running   0             75m
kube-system   calico-node-lhhbm                         1/1     Running   0             75m
kube-system   coredns-8474476ff8-2m528                  1/1     Running   0             71m
kube-system   coredns-8474476ff8-kk48k                  1/1     Running   0             71m
kube-system   dns-autoscaler-5ffdc7f89d-zgp9h           1/1     Running   0             71m
kube-system   kube-apiserver-node-1                     1/1     Running   0             125m
kube-system   kube-apiserver-node-2                     1/1     Running   0             83m
kube-system   kube-apiserver-node-3                     1/1     Running   0             83m
kube-system   kube-controller-manager-node-1            1/1     Running   1             124m
kube-system   kube-controller-manager-node-2            1/1     Running   1             83m
kube-system   kube-controller-manager-node-3            1/1     Running   1             83m
kube-system   kube-proxy-j7ggv                          1/1     Running   0             78m
kube-system   kube-proxy-kmmtv                          1/1     Running   0             78m
kube-system   kube-proxy-rckfr                          1/1     Running   0             78m
kube-system   kube-scheduler-node-1                     1/1     Running   1             124m
kube-system   kube-scheduler-node-2                     1/1     Running   1             83m
kube-system   kube-scheduler-node-3                     1/1     Running   1             83m
kube-system   nodelocaldns-9kd8x                        1/1     Running   0             71m
kube-system   nodelocaldns-d52q8                        1/1     Running   0             71m
kube-system   nodelocaldns-t9jp8                        1/1     Running   0             71m
```
---
### Создание тестового приложения
1. Git репозиторий с тестовым приложением и Dockerfile.
[nginx](https://github.com/ottvladimir/nginx/tree/main)

2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:

# Задеплоить в кластер prometheus-stack
1. 
```bash
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm install stable prometheus-community/kube-prometheus-stack
```
Настраиваю Prometheus на LoadBalancer.
```bash
$ kubectl edit svc stable-kube-prometheus-sta-prometheus
```
Меняю
```yaml
selector:
    app.kubernetes.io/name: prometheus
    prometheus: stable-kube-prometheus-sta-prometheus
  sessionAffinity: None
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```
на

```yaml
selector:
    app.kubernetes.io/name: prometheus
    prometheus: stable-kube-prometheus-sta-prometheus
  sessionAffinity: None
  type: LoadBalancer
```
Тоже самое для grafana
```yaml
  selector:
    app.kubernetes.io/instance: stable
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```
Меняю на 
```yaml
  selector:
    app.kubernetes.io/instance: stable
    app.kubernetes.io/name: grafana
  sessionAffinity: None
  type: LoadBalancer
```
app.kubernetes.io/instance: stable
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 8.3.6
    helm.sh/chart: grafana-6.22.0
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Настраиваю CI/CD GitLab

[Репозиторий](https://gitlab.com/ottvladimir/netology-diplom-nginx)

1. Настройка gitlab:
```bash
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-26c5n   kubernetes.io/service-account-token   3      6d5h
$ kubectl get secret default-token-26c5n -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```
Устанавливаю переменные:
[!image](images/gitlab_vars.png)
KUBE_TOKEN - token пользователя terraform
KUBE_URL - адрес кластера
REGISTRYID - id Container Registry
OAUTH - oauth token для авторизации в yc  
Интерфейс ci/cd сервиса доступен по [ссылке](https://gitlab.com/ottvladimir/netology-diplom-nginx/-/settings/ci_cd)
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---
## Как правильно задавать вопросы дипломному руководителю?

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в 
  материалах курса и ДЗ и только после этого спрашивать у дипломного 
  руководителя. Скилл поиска ответов пригодится вам в профессиональной 
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного 
  списка. Так дипломному руководителю будет проще отвечать на каждый из 
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой 
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». 
  Дипломный руководитель не сможет ответить на такой вопрос без 
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, 
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

