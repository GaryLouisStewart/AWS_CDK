#!/usr/bin/env bash
# provisions python stacks from scratch

#### vars ####
LIST="environments.txt"
# APP = the full path to the application you wish to specify.
# DIR = the directory where you wish to create your project.
# LANGUAGE = the language which you wish to use for the CDK project (e.g. python, typescript, C, Java, .NET)
# CDK_DEPLOY_ACCOUNT = the aws account which to deploy to, this is read in from the environments.txt file
# CDK_DEPLOY_REGION = the aws region to use for deployments e.g. eu-west-2
# AWS_PROFILE = the aws profile that is used
###################

############## do not include these functions in the case statement ##############
#### these are intended to be used locally and called from other functions #######

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
  read -rp "Please enter the AWS profile you wish to use: " PROFILE

  local profile=${PROFILE}
  local project=${PROJECT}
  local language="Python"
  printf '%s\n' "creating a base project to work from."

  mkdir -p "${project}" && cd "${project}" \
  && printf '%s\n' "Bootstraping the cdk toolkit" \
  && cdk init app --language=python \
  && source .env/bin/activate \
  && pip install -r requirements.txt \
  && cdk bootstrap --profile "${profile}"
}

function cdk_provision_project() {
    read -rp "Please enter the directory where your project is located: " DIR
    read -rp "Please enter the application name that you wish to deploy: " APP
    read -rp "Please enter the Language that you wish to use: " LANGUAGE
    read -rp "Do you wish to continue provisioning (y/n): " STATUS

    local deployments=${LIST}
    local language=${LANGUAGE}
    local status=${STATUS}
    local directory=${DIR}
    local application=${APP}

    if [ "${STATUS}" == "y" ]; then

        printf '%.0s-\n' {1..60} '%s\n'
        printf '%s\n' "Beginning setup of CDK project ${directory} using ${language}"
        printf '%.0s-' {1..60}

        # initalize a new directory to work from

        cdk_init

        # begin while loop in order to do our CDK deployment
        printf '%.0s-' {1..60}
        printf '%s\n' "Deploying CDK application: ${directory}/${application} using ${language}"
        printf '%.0s-' {1..60}

        while IFS= read -r line
        do
          f1=$(awk '{split($line,a,":"); print a[1]}')
          f2=$(awk '{split($line,a,":"); print a[2]}')
          cdk_deploy "${f1}" "${f2}" --app "${application}" || exit
        done < ${deployments}
    else
      printf '%s\n' "Error provision project: aborting" && exit 1
    fi
}

function usage() {
    printf '%s\n' "usage: [-c, --create | -d, --deploy | -i, --init  | -h, --help]"
    printf '%s\n' "-c  --create   creates a blank CDK project"
    printf '%s\n' "-d  --deploy   deploys a CDK project"
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
    -h| --help)
    usage
    ;;
    *)
      usage
esac



