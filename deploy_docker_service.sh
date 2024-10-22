#!/bin/sh

STACK_NAME=ekassir-int
SERVICE_NAME=ps_operhub

COMPOSE_FILE=(
     deploy_ps_operhub_migrate.yml
     deploy_ps_operhub-1.yml
     deploy_ps_operhub-2.yml
)

docker service rm ${STACK_NAME}_${SERVICE_NAME}-1
docker service rm ${STACK_NAME}_${SERVICE_NAME}-2
docker service rm ${STACK_NAME}_${SERVICE_NAME}_migrate

for secret in $(docker secret ls --quiet --filter "NAME=${STACK_NAME}_${SERVICE_NAME}"); do
    docker secret rm $secret
done

for deploy in "${COMPOSE_FILE[@]}"; do
    docker stack deploy --with-registry-auth -c $deploy $STACK_NAME
done
