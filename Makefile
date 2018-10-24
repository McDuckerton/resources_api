DOCKER := docker
DOCKER_COMPOSE := docker-compose
RESOURCES_CONTAINER := resources01

.PHONY: all
all: run

.PHONY:  nuke
nuke:
	${DOCKER} system prune -a --volumes

.PHONY: minty-fresh
minty-fresh:
	${DOCKER_COMPOSE} down --rmi all --volumes

.PHONY: rmi
rmi:
	${DOCKER} images -q | xargs docker rmi -f

.PHONY: rmdi
rmdi:
	${DOCKER} images -a --filter=dangling=true -q | xargs ${DOCKER} rmi

.PHONY: rm-exited-containers
rm-exited-containers:
	${DOCKER} ps -a -q -f status=exited | xargs ${DOCKER} rm -v

.PHONY: fresh-restart
fresh-restart: minty-fresh setup test run

.PHONY: run
run:
	${DOCKER_COMPOSE} up --build


.PHONY: build
build:
	${DOCKER_COMPOSE} build

# modify to have the initial creation and seeding
.PHONY: setup
setup: build
	${DOCKER_COMPOSE} run ${RESOURCES_CONTAINER} flask db_migrate create_tables
	${DOCKER_COMPOSE} run ${RESOURCES_CONTAINER} flask db stamp head
	${DOCKER_COMPOSE} run ${RESOURCES_CONTAINER} flask db_migrate init

# modify to accept argument to create a migration file
.PHONY: db_migrate
db_migrate:
	${DOCKER_COMPOSE} run ${RESOURCES_CONTAINER} rake db:migrate

