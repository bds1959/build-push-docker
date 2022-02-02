#!/usr/bin/env bash

echo $DOCKER_PASSWORD | docker login --username=$DOCKER_USERNAME $CONTAINER_REGISTRYURL --password-stdin
image_name=$REPOSITORY_NAME:$IMAGE_VERSION
image_url=$CONTAINER_REGISTRYURL/$DOCKER_USERNAME/$REPOSITORY_NAME:$IMAGE_VERSION
docker_file=$DOCKER_FILE
if [[ "${docker_file}" = "" ]]; then
    docker_file="."
fi
docker build -t ${image_name} ${docker_file}
docker tag ${image_name} ${image_url}
docker push ${image_url}

#output
echo "::set-output name=image_url::${image_url}"

# Login to Kubernetes Cluster.
if [ -n "$CLUSTER_ROLE_ARN" ]; then
    aws eks \
        --region ${AWS_REGION} \
        update-kubeconfig --name ${CLUSTER_NAME} \
        --role-arn=${CLUSTER_ROLE_ARN}
else
    aws eks \
        --region ${AWS_REGION} \
        update-kubeconfig --name ${CLUSTER_NAME} 
fi

# Helm Deployment
DEPS_UPDATE_COMMAND="helm dependency update ${DEPLOY_CHART_PATH}"
UPGRADE_COMMAND="helm upgrade --install --timeout ${TIMEOUT}"

if [ "$DEPLOY_ATOMIC" = "true" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --atomic"
fi

if [ "$DEPLOY_FORCE" = "true" ]; then
  UPGRADE_COMMAND="${UPGRADE_COMMAND} --force"
fi

for config_file in ${DEPLOY_CONFIG_FILES//,/ }
do
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -f ${config_file}"
done
if [ -n "$DEPLOY_NAMESPACE" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi
if [ -n "$DEPLOY_VALUES" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --set ${DEPLOY_VALUES}"
fi
UPGRADE_COMMAND="${UPGRADE_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH}"
echo "Executing: ${DEPS_UPDATE_COMMAND}"
${DEPS_UPDATE_COMMAND}
echo "Executing: ${UPGRADE_COMMAND}"
${UPGRADE_COMMAND}
