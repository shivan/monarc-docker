# Monarc docker image
This docker image contains the dockerized version of Monarc from NC3 (Https://monarc.lu).
It's a "Method for an Optimised aNalysis of Risks".
Since there is no official docker version, we created one by our selves.

## How to use locally with docker
To try it locally with docker, you can simply start with the docker-compose.yml example. It contains predefined values, ready to use.

## How to use in Kubernetes

Create two deployments.

### 1st Deployment: MariaDB
|Name     |Value|
|---------|----------|
|Container| monarc-db|
|Container Image|mariadb:10.5|
|Ports|- For remote access: 3306 TCP as ClusterIP|

Environment variables:

|Name|Value|
|-|-|
|MYSQL_ROOT_PASSWORD|yyyy|
|MYSQL_DATABASE|monarc_cli|
|MYSQL_USER|monarc|
|MYSQL_PASSWORD|xxxx|

Storage mounted to: /var/lib/mysql

### 2nd Deployment: Monarc
|Name     |Value|
|---------|----------|
|Container| monarc|
|Container Image|docker-registry-server.com/monarc:latest|
|Ports|- 80 TCP as ClusterIP|


Environment variables:

|Name|Value|
|-|-|
|DB_PASSWORD|xxxx|
|DB_ROOT_PASSWORD|yyyy|
|DB_HOST|monarc-db|

Storage mounted to: /var/lib/monarc/fo/data

### Create Ingress
Url: http://monarc.myserver.cloud/

Target service: monarc

ingress class: nginx