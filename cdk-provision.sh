#!/usr/bin/env bash
# provisions python stacks from scratch

#### vars ####
LIST="environments.txt"
# APP = the full path to the application you wish to specify.
# DIR = the directory where you wish to create your project.
# LANGUAGE = the language which you wish to use for the CDK project (e.g. python, typescript, C, Java, .NET)
# CDK_DEPLOY_ACCOUNT = the aws account which to deploy to, this is read in from the environments.txt file
# CDK_DEPLOY_REGION = the aws region to use for deployments e.g. eu-west-2
###################

### do not include this function in the case statement ####
### this is only to be called from other functions   ######

function cdk_deploy() {
    export CDK_DEPLOY_ACCOUNT=$1
    shift
    export CDK_DEPLOY_REGION=$2
    shift
    cdk deploy "$@"
}

###########################################################

function cdk_create() {
  read -rp "Please enter the project name you wish to create: " PROJECT
  local project=${PROJECT}
  local language="Python"
  printf '%s\n' "creating a base project to work from."
  mkdir -p "${project}" && cd "${project}" \
  && cdk init app --language=python \
  && source .env/bin/activate \
  && pip install -r requirements.txt
}

function cdk_init() {
  local directory=${DIR}
  local language=${LANGUAGE}

  read -rp "Please enter the name of the directory to initalize: " DIR
  printf '%s\n' "Creating directory: ${directory}" \
  mkdir -p "${directory}"  \
  && printf '%s\n' "Initalizing a new application using CDK" \
  && cd "${directory}"  && cdk init app --language="${language}"
}

function cdk_provision_project() {
    read -rp "Please enter the Language that you wish to use: " LANGUAGE
    read -rp "Do you wish to continue provisioning (y/n): " STATUS
    if [ "${STATUS}" == "y" ]; then

        printf '%.0s-\n' {1..60} '%s\n'
        printf '%s\n' "Beginning setup of CDK project ${DIR} using ${LANGUAGE}"
        printf '%.0s-' {1..60}

        # initalize a new directory to work from

        cdk_init

        # begin while loop in order to do our CDK deployment
        printf '%.0s-' {1..60}
        printf '%s\n' "Deploying CDK application: ${APP} using ${LANGUAGE}"
        printf '%.0s-' {1..60}

        while IFS= read -r line
        do
          f1=$(awk '{split($line,a,":"); print a[1]}')
          f2=$(awk '{split($line,a,":"); print a[2]}')
          app=${APP}
          cdk_deploy "${f1}" "${f2}" --app "${APP}" || exit
        done < ${LIST}
    else
      printf '%s\n' "Error provision project: aborting" && exit 1
    fi
}

function usage() {
    printf '%s\n' "usage: [-c, --create | -d, --deploy | -i, --init  | -h, --help]"
    printf '%s\n' "-c  --create   creates a blank CDK project"
    printf '%s\n' "-d  --deploy   deploys a CDK project"
    printf '%s\n' "-i  --init     initializes a CDK project"
    printf '%s\n' "-h  --help     shows this help menu"
    exit 1
}

opt=$1

case $opt
in
    -c| --create)
    cdk_create
    ;;
    -d| --deploy)
    cdk_provision_project
    ;;
    -i| --init)
    cdk_init
    ;;
    -h| --help)
    usage
    ;;
    *)
      usage
esac



