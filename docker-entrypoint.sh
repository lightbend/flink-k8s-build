#!/bin/sh

################################################################################
#   from https://github.com/apache/flink/blob/release-1.7/flink-container/docker/docker-entrypoint.sh
#   and https://github.com/docker-flink/docker-flink/blob/63b19a904fa8bfd1322f1d59fdb226c82b9186c7/1.7/scala_2.11-alpine/docker-entrypoint.sh
################################################################################

# If unspecified, the hostname of the container is taken as the JobManager address
JOB_MANAGER_RPC_ADDRESS=${JOB_MANAGER_RPC_ADDRESS:-$(hostname -f)}

drop_privs_cmd() {
    if [ $(id -u) != 0 ]; then
        # Don't need to drop privs if EUID != 0
        return
    elif [ -x /sbin/su-exec ]; then
        # Alpine
        echo su-exec flink
    else
        # Others
        echo gosu flink
    fi
}

JOB_MANAGER="jobmanager"
TASK_MANAGER="taskmanager"

CMD="$1"
shift

if [ "${CMD}" = "help" ]; then
    echo "Usage: $(basename $0) (${JOB_MANAGER}|${TASK_MANAGER}|help)"
    exit 0
elif [ "${CMD}" = "${JOB_MANAGER}" -o "${CMD}" = "${TASK_MANAGER}" ]; then
    if [ "${CMD}" = "${TASK_MANAGER}" ]; then
        TASK_MANAGER_NUMBER_OF_TASK_SLOTS=${TASK_MANAGER_NUMBER_OF_TASK_SLOTS:-$(grep -c ^processor /proc/cpuinfo)}

        sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" "$FLINK_HOME/conf/flink-conf.yaml"
        sed -i -e "s/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: $TASK_MANAGER_NUMBER_OF_TASK_SLOTS/g" "$FLINK_HOME/conf/flink-conf.yaml"
        echo "blob.server.port: 6124" >> "$FLINK_HOME/conf/flink-conf.yaml"
        echo "query.server.port: 6125" >> "$FLINK_HOME/conf/flink-conf.yaml"

        echo "Starting Task Manager"
        echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
        exec $(drop_privs_cmd) "$FLINK_HOME/bin/taskmanager.sh" start-foreground
    else
        sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" "$FLINK_HOME/conf/flink-conf.yaml"
        echo "blob.server.port: 6124" >> "$FLINK_HOME/conf/flink-conf.yaml"
        echo "query.server.port: 6125" >> "$FLINK_HOME/conf/flink-conf.yaml"
        echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
        exec $(drop_privs_cmd) "$FLINK_HOME/bin/jobmanager.sh" start-foreground "$@"
    fi
fi

exec "$@"