#!/usr/bin/env bash

FLINK_VERSION=1.8.0
FLINK_BASE_URL="$(curl -s https://www.apache.org/dyn/closer.cgi\?preferred\=true)flink/flink-${FLINK_VERSION}/"
FLINK_DIST_FILE_NAME="flink-${FLINK_VERSION}-src.tgz"
DOWNLOAD_FLINK_URL=${FLINK_BASE_URL}${FLINK_DIST_FILE_NAME}

# Directory for loading src
TMPDIR="flink_src"

# Directory for build version
DISTRO="flink"

rm -r ${TMPDIR}
rm -r ${DISTRO}
mkdir -p "${TMPDIR}"
mkdir -p "${DISTRO}"
chmod 777 "${TMPDIR}"
chmod 777 "${DISTRO}"

CURL_OUTPUT="${TMPDIR}/${FLINK_DIST_FILE_NAME}"

curl ${DOWNLOAD_FLINK_URL} --output ${CURL_OUTPUT}

# Untar source file and remove it

tar xvzf ${CURL_OUTPUT} -C ${TMPDIR}
rm ${CURL_OUTPUT}

# Update code
yes | cp -rf src/main/java/* ${TMPDIR}/flink-${FLINK_VERSION}/flink-runtime/src/main/java

# Build distribution for scala 2.11
cd ${TMPDIR}/flink-${FLINK_VERSION}
mvn clean package -pl flink-dist -am -Pscala-2.11 -Dscala-2.11 -DskipTests
cd ../..

# and save it
yes | cp -rf ${TMPDIR}/flink-${FLINK_VERSION}/flink-dist/target/flink-${FLINK_VERSION}-bin/flink-${FLINK_VERSION} ${DISTRO}/scala11
# Add Prometheus, Table and Queryable state jars to lib. Add additional jars if you need
mv ${DISTRO}/scala11/opt/flink-metrics-prometheus-${FLINK_VERSION}.jar ${DISTRO}/scala11/lib/
mv ${DISTRO}/scala11/opt/flink-queryable-state-runtime_2.11-${FLINK_VERSION}.jar ${DISTRO}/scala11/lib/
mv ${DISTRO}/scala11/opt/flink-table_2.11-${FLINK_VERSION}.jar ${DISTRO}/scala11/lib/

# Add Prometheus metric reporter to config
echo "metrics.reporters: prom" >> "${DISTRO}/scala11/conf/flink-conf.yaml"
echo "metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter" >> "${DISTRO}/scala11/conf/flink-conf.yaml"
echo "metrics.reporter.prom.port: 9249" >>  "${DISTRO}/scala11/conf/flink-conf.yaml"


# Build distribution for scala 2.12
cd ${TMPDIR}/flink-${FLINK_VERSION}
mvn clean package -pl flink-dist -am -Pscala-2.12 -Dscala-2.12 -DskipTests
cd ../..

# and save it
yes | cp -rf ${TMPDIR}/flink-${FLINK_VERSION}/flink-dist/target/flink-${FLINK_VERSION}-bin/flink-${FLINK_VERSION} ${DISTRO}/scala12
# Add Prometheus, Table and Queryable state jars to lib. Add additional jars if you need
mv ${DISTRO}/scala12/opt/flink-metrics-prometheus-${FLINK_VERSION}.jar ${DISTRO}/scala12/lib/
mv ${DISTRO}/scala12/opt/flink-queryable-state-runtime_2.12-${FLINK_VERSION}.jar ${DISTRO}/scala12/lib/
mv ${DISTRO}/scala12/opt/flink-table_2.12-${FLINK_VERSION}.jar ${DISTRO}/scala12/lib/

# Add Prometheus metric reporter to config
echo "metrics.reporters: prom" >> "${DISTRO}/scala12/conf/flink-conf.yaml"
echo "metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter" >> "${DISTRO}/scala12/conf/flink-conf.yaml"
echo "metrics.reporter.prom.port: 9249" >>  "${DISTRO}/scala12/conf/flink-conf.yaml"

docker build --build-arg flink_dist="${DISTRO}/scala11" -f Dockerfile_alpine -t lightbend/flink:${FLINK_VERSION}_scala_2.11_alpine .
docker build --build-arg flink_dist="${DISTRO}/scala12" -f Dockerfile_alpine -t lightbend/flink:${FLINK_VERSION}_scala_2.12_alpine .
docker build --build-arg flink_dist="${DISTRO}/scala11" -f Dockerfile_debian -t lightbend/flink:${FLINK_VERSION}_scala_2.11_debian .
docker build --build-arg flink_dist="${DISTRO}/scala12" -f Dockerfile_debian -t lightbend/flink:${FLINK_VERSION}_scala_2.12_debian .
docker build --build-arg flink_dist="${DISTRO}/scala11" -f Dockerfile_ubuntu -t lightbend/flink:${FLINK_VERSION}_scala_2.11_ubuntu .
docker build --build-arg flink_dist="${DISTRO}/scala12" -f Dockerfile_ubuntu -t lightbend/flink:${FLINK_VERSION}_scala_2.12_ubuntu .