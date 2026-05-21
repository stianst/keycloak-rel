#!/bin/bash -e

cd $(dirname $0)

mkdir -p ../.repo
cd ../.repo

if [ -d keycloak ]; then
  echo "======================================================================"
  echo "Updating repository"
  echo "----------------------------------------------------------------------"

  cd keycloak
  git fetch -p origin
  git fetch -p private
else
  echo "======================================================================"
  echo "Cloning repository"
  echo "----------------------------------------------------------------------"

  git clone https://github.com/keycloak/keycloak.git

  cd keycloak
  git remote add private https://github.com/keycloak/keycloak-private.git
  git fetch -p private

  gh repo set-default keycloak/keycloak-private
fi