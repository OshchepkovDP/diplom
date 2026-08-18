# Дипломный практикум в Яндекс.Облаке - Ощепков Дмитрий

- Цели:
- Этапы выполнения:
- Создание облачной
- Создание кластера Kubernetes
- Создание тестового приложения
- Подготовка систем «мониторинга» и развертывание приложений
- Установка и настройка CI/CD
- Что необходимо для сдачи задания?
- Как правильно задавать вопросы дипломному руководителю?

Перед началом работы над дипломным заданием изучите Инструкцию по экономии облачных ресурсов .

### Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать кластер Kubernetes.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Установите компакт-диск для автоматического развертывания приложений.

## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи Terraform .

Особенности выполнения:

- Бюджет купона ограничен, что следует учитывать при проектировании труда и использовании ресурсов; Для облачного k8s используйте региональный мастер(неотказоустойчивый). 
  Для самостоятельного размещения k8s минимизируйте ресурс ВМ и долю ЦПУ. В верхних вариантах активируются отключаемые ВМ для рабочих узлов.

Предварительная подготовка к установке и запуску кластера Kubernetes.

1. Создать сервисный аккаунт, который в дальнейшем будет использоваться Terraform для работы с инфраструктурой с адаптерами и предоставляемыми правами. Не стоит использовать права 
   суперпользователя

2. Подготовьте бэкенд для Terraform:
   a. Рекомендуемый вариант: Бакет S3 в созданном ЯО аккаунте(создание бакета через TF) б. Альтернативный вариант: Terraform Cloud

3. Создайте конфигурацию Terra из созданного ранее бакета в качестве бекенда для хранения стейт-файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и в основном 
   следует сохранять в разных папках.

4. Создайте VPC с подсетями в разных зонах доступности.

5. Убедитесь, что теперь вы можете выполнить настройку команды terraform destroyи terraform applyбез дополнительных ручных действий.

6. В случае использования Terraform Cloud в качестве серверной части убедитесь, что применение изменений успешно проходит с помощью веб-интерфейса Terraform Cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и использован для создания с помощью Terraform, возможно, без дополнительных ручных действий, основной контур сохраняется в бакете или Terraform Cloud.

2. Полученный материал является предварительным, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Создание кластера Kubernetes

На этом этапе необходимо создать кластер Kubernetes на базе предварительно созданной рабочей силы. Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка кластера Kubernetes.
   а. При помощи Terraform подготовьте как минимум 3 виртуальных вычислительных облака для создания Kubernetes-кластера. Тип решения машины следует выбирать самостоятельно с учетом требований к производительности и стоимости. Если в перспективе поймете, что необходимо изменить тип инстанса, воспользуйтесь Terraform для внесения изменений.
   б. Подготовить возможную схему, можно воспользоваться, например Kubespray
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их с помощью Terraform.

2. Альтернативный вариант: использовать сервис Yandex Managed Service для Kubernetes
   а. С помощью ресурса terraform для kubernetes создайте региональный мастер kubernetes с размещением узлов в разных 3 подсетях
   б. С помощью ресурса terraform для группы узлов Kubernetes

Ожидаемый результат:

1. Работоспособный кластер Kubernetes.

2. В файле ~/.kube/configнаходятся данные для доступа к кластеру.

3. Отработка команды kubectl get pods --all-namespacesбез ошибок.

### Создание тестового приложения

Для перехода к следующему этапу необходимо разработать приложение к испытаниям, имитирующее рабочее приложение, разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:
   а. Создайте отдельные репозитории git с простым конфигом nginx, который будет передавать статические данные.
   б. Подготовьте Dockerfile для создания образа приложения.

2. Альтернативный вариант:
   а. Используйте любой другой код, главное, чтобы Dockerfile был создан самостоятельно.

Ожидаемый результат:

1. Git репозиторий с тестовыми приложениями и Dockerfile.

2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или Yandex Container Registry, созданный также с помощью terraform.

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер prometheus, grafana, alertmanager, экспортер основных метрик Kubernetes.

2. Задеплоить тестовое приложение, например, nginx сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользоваться пакетом kube-prometheus, который уже включает в себя Kubernetes оператор для grafana, prometheus, alertmanager и node_exporter. Альтернативный вариант - 
использовать набор helm чартов от bitnami.
Деплой инфраструктуры в terraform pipeline
Если на первом этапе вы не воспользовались Terraform Cloud, то задеплойте и настройте в кластере atlantis для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом 
комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.

2. Http доступ на 80 порту к web интерфейсу grafana.

3. Дашборды в grafana отображающие состояние Kubernetes кластера.

4. Http доступ на 80 порту к тестовому приложению.

5. Atlantis или terraform cloud или ci/cd-terraform

Ответ:

# Дипломный практикум — Яндекс.Облако

## Цель

Развернуть облачную инфраструктуру в Яндекс.Облаке с использованием Terraform,
установить кластер Kubernetes с помощью Kubespray, настроить мониторинг и CI/CD.

---

## Используемые технологии

- **Облако:** Yandex Cloud
- **IaC:** Terraform
- **Кластер K8s:** Kubespray (Ansible)
- **Мониторинг:** kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
- **CI/CD:** GitHub Actions
- **Container Registry:** Yandex Container Registry
- **CNI:** Calico

---

## Структура репозитория
.
├── terraform/
│   ├── bootstrap/        # Создание SA и S3-бакета для tfstate
│   └── infrastructure/   # VPC, ВМ, Registry, KMS, Security Groups
├── ansible/
│   ├── kubespray/        # Git submodule — Kubespray
│   ├── inventory/        # Inventory для кластера
│   ├── group_vars/       # Переменные Kubespray
│   ├── playbook.yml      # Основной плейбук
│   ├── pre_install.yml   # Подготовка нод
│   └── post_install.yml  # Получение kubeconfig
├── kubernetes/
│   ├── app/              # Манифесты тестового приложения
│   └── monitoring/       # Установка мониторинга (Helm values)
├── app/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── html/index.html
└── .github/workflows/
├── ci.yaml           # CI: сборка образа при push в app/
├── cd.yml            # CD: деплой при создании тега v*..
└── terraform.yml     # Terraform plan/apply при push в terraform/

---

## 1. Создание облачной инфраструктуры

**Terraform конфигурации:** [terraform/](terraform/)

### Этапы:

1. Bootstrap — создание сервисного аккаунта и S3-бакета для хранения tfstate:

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="yc_token=$(yc iam create-token)"
Основная инфраструктура — VPC, ВМ, Registry, KMS:
```
```
cd terraform/infrastructure
terraform init \
  -backend-config="bucket=tfstate-b1g2426oq802iot2pt34" \
  -backend-config="access_key=<S3_ACCESS_KEY>" \
  -backend-config="secret_key=<S3_SECRET_KEY>"
terraform apply
```

### Созданные ресурсы:

- Сервисный аккаунт terraform-sa с минимальными правами
- S3-бакет tfstate-b1g2426oq802iot2pt34 для хранения state
- VPC k8s-network с подсетями в 3 зонах доступности
- 3 виртуальных машины (1 master + 2 workers)
- Yandex Container Registry diploma-registry
- KMS-ключ для шифрования secrets в K8s
- Security Groups для управления трафиком

2. Создание кластера Kubernetes

Ansible конфигурации: `ansible`

Кластер развёрнут с помощью `Kubespray:`

```
cd ansible
./generate_inventory.sh
ansible-playbook -i inventory/hosts.yaml playbook.yml
```

### Параметры кластера:

|       Параметр    |         Значение        |
|-------------------|-------------------------|
| Версия Kubernetes |         v1.28.6         |
|        CNI        |         Calico          |
| Container runtime |       containerd        |
|        Нод        | 3 (1 master, 2 workers) |

```
kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   ...   v1.28.6
k8s-worker-1   Ready    <none>          ...   v1.28.6
k8s-worker-2   Ready    <none>          ...   v1.28.6
```

3. Тестовое приложение

Исходный код: `app`

Nginx-сервер, отдающий статическую страницу с версией.

Dockerfile: `app/Dockerfile`

Образ в Yandex Container Registry:

```
cr.yandex/crpe9rio3jbnbsrgurqe/diplom-app:latest
cr.yandex/crpe9rio3jbnbsrgurqe/diplom-app:v1.0.0
```

![Ссылка на приложение](http://158.160.34.186:30080)

4. Мониторинг

Конфигурации: `kubernetes/monitoring`

Развёрнут стек `kube-prometheus-stack:`

- Prometheus — сбор метрик
- Grafana — визуализация
- Alertmanager — алерты
- node-exporter — метрики нод
- kube-state-metrics — метрики K8s объектов
- Grafana: http://158.160.34.186:30080/grafana/

Установка:

```
cd kubernetes/monitoring
bash install.sh
kubectl apply -f ingress.yaml
```

5. CI/CD
Workflows: `.github/workflows`

CI — сборка образа
Триггер: push в ветку `main/develop` при изменениях в `app`

Workflow: `ci.yaml`

- Авторизация в Yandex Container Registry
- Сборка Docker-образа
- Push тегов `latest` и <git-sha>

CD — деплой в кластер

Триггер: создание тега вида `v*.*.*`

Workflow: `cd.yml`

- Сборка образа с тегом версии
- Деплой в Kubernetes (`diplom-app namespace`)
- Ожидание успешного rollout

Terraform CI/CD
Триггер: push в `terraform/infrastructure/**`

Workflow: `terraform.yml`

- terraform plan на Pull Request (с комментарием к PR)
- terraform apply при merge в main

6. Ссылки

[Репозиторий](https://github.com/OshchepkovDP/diplom)

[Тестовое приложение](http://158.160.34.186:30080/)

[Grafana](http://158.160.34.186:30080/grafana/)

[Docker образ](https://console.yandex.cloud/folders/b1g2426oq802iot2pt34/container-registry/registries/crpe9rio3jbnbsrgurqe/overview/diplom-app/image/crpgmorug19rfp14vrsl/overview)

[GitHub Actions](https://github.com/OshchepkovDP/diplom/actions)

7. Скриншоты

![pipline_1.jpg](https://github.com/OshchepkovDP/diplom/blob/main/img/pipline_1.jpg)

![pipline_terraform_CI_CD.jpg](https://github.com/OshchepkovDP/diplom/blob/main/img/pipline_terraform_CI_CD.jpg)

![pipline_CI.jpg](https://github.com/OshchepkovDP/diplom/blob/main/img/pipline_CI.jpg)

![pipline_CD.jpg](https://github.com/OshchepkovDP/diplom/blob/main/img/pipline_CD.jpg)

![Yandex_cloud.jpg](https://github.com/OshchepkovDP/diplom/blob/main/img/Yandex_cloud.jpg)
