#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}" || exit

# shellcheck disable=SC1091
source utility.sh

start() {
  if [[ ! -f backup/settings.env ]] || [[ ! -f .env ]]; then
    setup
  else
    docker-compose --env-file .env -f docker-compose.yml up -d
  fi
}

stop() {
  docker-compose --env-file .env -f docker-compose.yml stop
}

down() {
  docker-compose --env-file .env -f docker-compose.yml down
}

shutdown() {
  if [[ ! -f backup/settings.env ]]; then
    echo_warning "Unable to erase as nothing is configured!"
    exit 0 #no need to proceed as nothing was configured
  fi

  if [[ -z ${SHUTDOWN_CONFIRMED} ]] || [[ ${SHUTDOWN_CONFIRMED} -ne 1 ]]; then
    # ask about confirmation if it is not confirmed in scope of CE
    echo_warning "Shutdown will erase all settings and data for \"${BASEDIR}\"!"
    confirm "" "      Do you want to continue?" "n"
    if [[ $? -eq 0 ]]; then
      exit
    fi
  fi

  docker-compose --env-file .env -f docker-compose.yml down -v

  rm -f backup/settings.env
  rm -f .env
  rm -f s3.env
  rm -f stf.env
  rm -f appium.env
}

version() {
  source .env.original
  echo
  echo -e "redroid: ${REDROID_VERSION}"
  echo -e "mcloud-device: ${DEVICE_VERSION}"
  echo -e "appium: ${APPIUM_VERSION}"
  echo -e "uploader: ${UPLOADER_VERSION}"
  echo
}

set_mcloud_settings () {
  echo
  # Zebrunner MCloud STF URL
  local is_confirmed=0
  while [[ $is_confirmed -eq 0 ]]; do
    read -r -p "Protocol [$ZBR_PROTOCOL]: " local_protocol
    if [[ ! -z $local_protocol ]]; then
      ZBR_PROTOCOL=$local_protocol
    fi

    read -r -p "Fully qualified domain name (ip) [$ZBR_HOSTNAME]: " local_hostname
    if [[ ! -z $local_hostname ]]; then
      ZBR_HOSTNAME=$local_hostname
    fi

    read -r -p "Port [$ZBR_MCLOUD_PORT]: " local_port
    if [[ ! -z $local_port ]]; then
      ZBR_MCLOUD_PORT=$local_port
    fi

    echo
    confirm "Zebrunner MCloud STF URL: $ZBR_PROTOCOL://$ZBR_HOSTNAME:$ZBR_MCLOUD_PORT/stf" "Continue?" "y"
    is_confirmed=$?
    echo
  done

  export ZBR_PROTOCOL=$ZBR_PROTOCOL
  export ZBR_HOSTNAME=$ZBR_HOSTNAME
  export ZBR_MCLOUD_PORT=$ZBR_MCLOUD_PORT

  # STF Settings
  if [ -z $ZBR_STF_RETHINKDB ]; then
    ZBR_STF_RETHINKDB=tcp://$ZBR_HOSTNAME:28015
  fi

  if [ -z $ZBR_STF_PROVIDER_CONNECT_PUSH ]; then
    ZBR_STF_PROVIDER_CONNECT_PUSH=tcp://$ZBR_HOSTNAME:7270
  fi

  if [ -z $ZBR_STF_PROVIDER_CONNECT_SUB ]; then
    ZBR_STF_PROVIDER_CONNECT_SUB=tcp://$ZBR_HOSTNAME:7250
  fi

  is_confirmed=0
  while [[ $is_confirmed -eq 0 ]]; do
    read -r -p "STF RethinkDB [$ZBR_STF_RETHINKDB]: " local_rethinkdb
    if [[ ! -z $local_rethinkdb ]]; then
      ZBR_STF_RETHINKDB=$local_rethinkdb
    fi

    read -r -p "STF dev triproxy push [$ZBR_STF_PROVIDER_CONNECT_PUSH]: " local_stf_push
    if [[ ! -z $local_stf_push ]]; then
      ZBR_STF_PROVIDER_CONNECT_PUSH=$local_stf_push
    fi

    read -r -p "STF dev triproxy sub [$ZBR_STF_PROVIDER_CONNECT_SUB]: " local_stf_sub
    if [[ ! -z $local_stf_sub ]]; then
      ZBR_STF_PROVIDER_CONNECT_SUB=$local_stf_sub
    fi

    echo
    echo "STF Settings:"
    echo "RethinkDB: $ZBR_STF_RETHINKDB"
    echo "Dev triproxy push: $ZBR_STF_PROVIDER_CONNECT_PUSH"
    echo "Dev triproxy sub: $ZBR_STF_PROVIDER_CONNECT_SUB"

    confirm "" "Continue?" "y"
    is_confirmed=$?
    echo
  done

  export ZBR_STF_RETHINKDB=$ZBR_STF_RETHINKDB
  export ZBR_STF_PROVIDER_CONNECT_PUSH=$ZBR_STF_PROVIDER_CONNECT_PUSH
  export ZBR_STF_PROVIDER_CONNECT_SUB=$ZBR_STF_PROVIDER_CONNECT_SUB

  # STF Provider host and name
  is_confirmed=0
  while [[ $is_confirmed -eq 0 ]]; do

    if [ -z $ZBR_STF_PROVIDER_HOSTNAME ]; then
      ZBR_STF_PROVIDER_HOSTNAME=$EXTERNAL_IP
    fi

    read -r -p "STF Provider host or public ip [$ZBR_STF_PROVIDER_HOSTNAME]: " local_stf_hostname
    if [[ ! -z $local_stf_hostname ]]; then
      ZBR_STF_PROVIDER_HOSTNAME=$local_stf_hostname
    fi

    read -r -p "STF Provider Name [$ZBR_STF_PROVIDER_NAME]: " local_stf_provider_name
    if [[ ! -z $local_stf_provider_name ]]; then
      ZBR_STF_PROVIDER_NAME=$local_stf_provider_name
    fi

    echo
    echo "STF Provider host: $ZBR_STF_PROVIDER_HOSTNAME"
    echo "STF Provider name: $ZBR_STF_PROVIDER_NAME"

    confirm "" "Continue?" "y"
    is_confirmed=$?
    echo
  done

  export ZBR_STF_PROVIDER_HOSTNAME=$ZBR_STF_PROVIDER_HOSTNAME
  export ZBR_STF_PROVIDER_NAME=$ZBR_STF_PROVIDER_NAME

  # Selenium grid host:port
  is_confirmed=0
  while [[ $is_confirmed -eq 0 ]]; do
    read -r -p "Selenium Grid host [$ZBR_SELENIUM_HOST]: " local_selenium_host
    if [[ ! -z $local_selenium_host ]]; then
      ZBR_SELENIUM_HOST=$local_selenium_host
    fi

    read -r -p "Selenium Grid port [$ZBR_SELENIUM_PORT]: " local_selenium_port
    if [[ ! -z $local_selenium_port ]]; then
      ZBR_SELENIUM_PORT=$local_selenium_port
    fi

    echo
    confirm "Selenium grid host:port : $ZBR_SELENIUM_HOST:$ZBR_SELENIUM_PORT" "Continue?" "y"
    is_confirmed=$?
    echo
  done

  export ZBR_SELENIUM_HOST=$ZBR_SELENIUM_HOST
  export ZBR_SELENIUM_PORT=$ZBR_SELENIUM_PORT
}

set_aws_storage_settings() {
  # AWS S3 storage
  echo
  echo "AWS S3 storage:"

  local is_confirmed=0
  while [[ $is_confirmed -eq 0 ]]; do
    read -r -p "Region [$ZBR_STORAGE_REGION]: " local_region
    if [[ ! -z $local_region ]]; then
      ZBR_STORAGE_REGION=$local_region
    fi

    read -r -p "Bucket [$ZBR_STORAGE_BUCKET]: " local_bucket
    if [[ ! -z $local_bucket ]]; then
      ZBR_STORAGE_BUCKET=$local_bucket
    fi

    read -r -p "Access key [$ZBR_STORAGE_ACCESS_KEY]: " local_access_key
    if [[ ! -z $local_access_key ]]; then
      ZBR_STORAGE_ACCESS_KEY=$local_access_key
    fi

    read -r -p "Secret key [$ZBR_STORAGE_SECRET_KEY]: " local_secret_key
    if [[ ! -z $local_secret_key ]]; then
      ZBR_STORAGE_SECRET_KEY=$local_secret_key
    fi

    if [[ -z $ZBR_S3_KEY_PATTERN ]]; then
      ZBR_S3_KEY_PATTERN=s3://$ZBR_STORAGE_BUCKET/artifacts/test-sessions
    fi
    read -r -p "Upload folder [$ZBR_S3_KEY_PATTERN]: " local_value
    if [[ ! -z $local_value ]]; then
      ZBR_S3_KEY_PATTERN=$local_value
    fi

    echo
    echo "Region: $ZBR_STORAGE_REGION"
    echo "Bucket: $ZBR_STORAGE_BUCKET"
    echo "Access key: $ZBR_STORAGE_ACCESS_KEY"
    echo "Secret key: $ZBR_STORAGE_SECRET_KEY"
    echo "Folder: $ZBR_S3_KEY_PATTERN"
    confirm "" "Continue?" "y"
    is_confirmed=$?
  done

  export ZBR_STORAGE_REGION=$ZBR_STORAGE_REGION
  export ZBR_STORAGE_BUCKET=$ZBR_STORAGE_BUCKET
  export ZBR_STORAGE_ACCESS_KEY=$ZBR_STORAGE_ACCESS_KEY
  export ZBR_STORAGE_SECRET_KEY=$ZBR_STORAGE_SECRET_KEY
  export ZBR_S3_KEY_PATTERN=$ZBR_S3_KEY_PATTERN
}

setup() {
  # load default interactive installer settings

  source backup/settings.env.original
  # load ./backup/settings.env if exist to declare ZBR* vars from previous run!
  if [[ -f backup/settings.env ]]; then
    source backup/settings.env
  fi

  source .env.original
  # load current .env if exist to read actual vars even manually updated!
  if [[ -f .env ]]; then
    source .env
  fi

  source stf.env.original
  # load current stf.env if exist to read actual vars even manually updated!
  if [[ -f stf.env ]]; then
    source stf.env
  fi

  source appium.env.original
  # load current appium.env if exist to read actual vars even manually updated!
  if [[ -f appium.env ]]; then
    source appium.env
  fi

  source s3.env.original
  # load current s3.env if exist to read actual vars even manually updated!
  if [[ -f s3.env ]]; then
    source s3.env
  fi

  EXTERNAL_IP=$(curl -s ifconfig.me)

  echo
  confirm "Register ReDroid agent in Zebrunner Device Farm?" "Register?" "$ZBR_STF_REGISTER"
  if [[ $? -eq 1 ]]; then
    ZBR_STF_REGISTER=1
    set_mcloud_settings
  fi

  confirm "Use AWS S3 bucket for storing test artifacts (logs and video)?" "Use?" "$ZBR_AWS_S3_ENABLED"
  if [[ $? -eq 1 ]]; then
    ZBR_AWS_S3_ENABLED=1
    set_aws_storage_settings
  fi

  # export all ZBR* variables to save user input
  export_settings

  # .env
  cp .env.original .env
  replace .env "EXTERNAL_IP=" "EXTERNAL_IP=$EXTERNAL_IP"

  # stf.env
  cp stf.env.original stf.env
  replace stf.env "PUBLIC_IP_PROTOCOL=" "PUBLIC_IP_PROTOCOL=${ZBR_PROTOCOL}"
  replace stf.env "STF_PROVIDER_PUBLIC_IP=" "STF_PROVIDER_PUBLIC_IP=${ZBR_HOSTNAME}"
  replace stf.env "PUBLIC_IP_PORT=" "PUBLIC_IP_PORT=${ZBR_MCLOUD_PORT}"

  replace stf.env "STF_PROVIDER_NAME=redroid-agent" "STF_PROVIDER_NAME=$ZBR_STF_PROVIDER_NAME"

  replace stf.env "RETHINKDB_PORT_28015_TCP=" "RETHINKDB_PORT_28015_TCP=$ZBR_STF_RETHINKDB"
  replace stf.env "STF_PROVIDER_CONNECT_PUSH=" "STF_PROVIDER_CONNECT_PUSH=$ZBR_STF_PROVIDER_CONNECT_PUSH"
  replace stf.env "STF_PROVIDER_CONNECT_SUB=" "STF_PROVIDER_CONNECT_SUB=$ZBR_STF_PROVIDER_CONNECT_SUB"
  replace stf.env "STF_PROVIDER_HOST=" "STF_PROVIDER_HOST=$ZBR_STF_PROVIDER_HOSTNAME"
  replace stf.env "DEVICE_UDID=" "DEVICE_UDID=$ZBR_STF_PROVIDER_HOSTNAME:5555"


  cp appium.env.original appium.env
  if [ $ZBR_STF_REGISTER -eq 1 ]; then
    replace appium.env "CONNECT_TO_GRID=false" "CONNECT_TO_GRID=true"
  else
    replace appium.env "DEFAULT_CAPABILITIES=true" "DEFAULT_CAPABILITIES=false"
  fi

  replace appium.env "ANDROID_DEVICE=" "ANDROID_DEVICE=$EXTERNAL_IP"
  replace appium.env "DEVICE_UDID=" "DEVICE_UDID=$EXTERNAL_IP:5555"
  replace appium.env "SELENIUM_HOST=" "SELENIUM_HOST=$ZBR_SELENIUM_HOST"
  replace appium.env "SELENIUM_PORT=" "SELENIUM_PORT=$ZBR_SELENIUM_PORT"
  replace appium.env "STF_PROVIDER_HOST=" "STF_PROVIDER_HOST=$ZBR_STF_PROVIDER_HOSTNAME"
  replace appium.env "DEVICE_NAME=" "DEVICE_NAME=Redroid"

  # s3.env
  cp s3.env.original s3.env
  if [ $ZBR_AWS_S3_ENABLED -eq 1 ]; then
    replace s3.env "AWS_DEFAULT_REGION=" "AWS_DEFAULT_REGION=$ZBR_STORAGE_REGION"
    replace s3.env "AWS_ACCESS_KEY_ID=" "AWS_ACCESS_KEY_ID=$ZBR_STORAGE_ACCESS_KEY"
    replace s3.env "AWS_SECRET_ACCESS_KEY=" "AWS_SECRET_ACCESS_KEY=$ZBR_STORAGE_SECRET_KEY"
    replace s3.env "S3_KEY_PATTERN=" "S3_KEY_PATTERN=$ZBR_S3_KEY_PATTERN"
  fi

  echo_warning "Your services needs to be started after setup."
  confirm "" "      Start now?" "y"
  if [[ $? -eq 1 ]]; then
    start
  fi
}

echo_help() {
  echo "
      Usage: ./zebrunner.sh [option]
      Flags:
          --help | -h    Print help
      Arguments:
      	  start          Start container
      	  stop           Stop and keep container
      	  restart        Restart container
      	  down           Stop and remove container
      	  shutdown       Stop and remove container, clear volumes
          version        Version of container
  "
  echo_telegram
  echo
  exit 0
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    down
    start
    ;;
  down)
    down
    ;;
  shutdown)
    shutdown
    ;;
  version)
    version
    ;;
  setup)
    setup
    ;;
  --help | -h)
    echo_help
    ;;
  *)
    echo_help
    exit 1
    ;;
esac
