#!/usr/bin/env bash
set -e

FLINK_VERSION=1.8.0

SCRIPT=$(basename ${BASH_SOURCE[0]})
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

cd "$ROOT_DIR"

help() {
  cat <<EOF
Build Flink Docker images with integrated Prometheus exporter for metrics. Push them to Docker Hub.
$0 [-h|--help] [-n|--no-push]
where:
-h | --help     Show this message and exit
-n | --no-push  Don't push the Docker images to Lightbend's Docker Hub account
EOF
}

do_push=true
while [[ $# -gt 0 ]]
do
  case $1 in
    -h|--h*)
      help
      exit 0
      ;;
    -n|--no*)
      do_push=false
      ;;
    -*)
      echo "$0: ERROR: Unrecognized option $1"
      help
      exit 1
      ;;
  esac
  shift
done

dockerfiles=(
  Dockerfile
  Dockerfile_scala12
  Dockerfile_alpine
  Dockerfile_alpine_scala12
  Dockerfile_ubuntu
  Dockerfile_ubuntu_scala12)

declare -A suffixes

suffixes[Dockerfile]="scala_2.11"
suffixes[Dockerfile_scala12]="scala_2.12"
suffixes[Dockerfile_alpine]="scala_2.11-alpine"
suffixes[Dockerfile_alpine_scala12]="scala_2.12-alpine"
suffixes[Dockerfile_ubuntu]="scala_2.11-ubuntu"
suffixes[Dockerfile_ubuntu_scala12]="scala_2.12-ubuntu"

for f in ${dockerfiles[@]}
do
  suffix=${suffixes[$f]}
  $NOOP docker build -f $f -t lightbend/flink:$FLINK_VERSION-$suffix .
  $do_push && $NOOP docker push lightbend/flink:$FLINK_VERSION-$suffix
done
