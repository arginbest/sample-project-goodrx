#!/usr/bin/env bash

if [ -z "$1" ]
then
  echo -e "\nUsage: ./build.sh <path_to_Docker_image_on_public_registry>\n"
else
  IMAGE_NAME=$1
  echo $IMAGE_NAME

  echo -e "\n##################################\n\nBuilding Docker image\n\n##################################\n"

  docker build -t $IMAGE_NAME -f docker/Dockerfile docker/
  echo -e "\n##################################\n\nPushing Docker image to public registry\n\n##################################\n"

  docker push $IMAGE_NAME

  echo -e "\n##################################\n\nCreating keypair for EC2 instances\n\n##################################\n"
  ssh-keygen -t rsa -b 4096 -C "waltisfrozen@gmail.com" -P "" -f ./terraform/goodrx

  echo -e "\n##################################\n\nInitializing Terraform\n\n##################################\n"

  cd terraform
  terraform init
  terraform plan -var "image_name=$IMAGE_NAME"

  echo -e "\n##################################\n\nApplying Terraform \n\n##################################\n"
  terraform apply -var "image_name=$IMAGE_NAME" -auto-approve
fi
