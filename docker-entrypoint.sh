#!/bin/bash

################################################################################
#   from https://github.com/apache/flink/blob/release-1.8/flink-container/docker/docker-entrypoint.sh
#   and https://github.com/docker-flink/docker-flink/blob/master/1.8/scala_2.12-alpine/docker-entrypoint.sh
################################################################################

drop_privs_cmd() {
    if [[ $(id -u) != 0 ]]; then
        # Don't need to drop privs if EUID != 0
        return
    elif [[ -x /sbin/su-exec ]]; then
        # Alpine
        echo su-exec flink
    else
        # Others
        echo gosu flink
    fi
}

JOB_MANAGER="jobmanager"
JOB_CLUSTER="jobcluster"
TASK_MANAGER="taskmanager"

CMD="$1"


if [[ "${CMD}" = "help" ]]; then
    echo "Usage: $(basename $0) (${JOB_MANAGER}|${JOB_CLUSTER}|${TASK_MANAGER}|help)"
    exit 0
elif [[ "${CMD}" = "${JOB_MANAGER}" || "${CMD}" = "${JOB_CLUSTER}" || "${CMD}" = "${TASK_MANAGER}" ]]; then
    shift
    sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" "$FLINK_HOME/conf/flink-conf.yaml"
    echo "metrics.internal.query-service.port: ${CONTAINER_METRIC_PORT}" >> "$FLINK_HOME/conf/flink-conf.yaml"
    echo "rest.port: 8081" >> "$FLINK_HOME/conf/flink-conf.yaml"
    echo "blob.server.port: 6124" >> "$FLINK_HOME/conf/flink-conf.yaml"
    echo "query.server.port: 6125" >> "$FLINK_HOME/conf/flink-conf.yaml"

    # Update parallelism
    if [[ -z "${PARALLELISM}" ]]; then
        echo "Using default parralelism of 1"
    else
        sed -i -e "s/parallelism.default: 1/parallelism.default: ${PARALLELISM}/g" "$FLINK_HOME/conf/flink-conf.yaml"
        echo "Using default parralelism of ${PARALLELISM}"
    fi

    # Use HA, if checkpoint is defined
    if [[ -z "${CHECKPOINTDIR}" ]]; then
        echo "No checkpoint defined"
    else
        echo "high-availability: filesystem" >> "$FLINK_HOME/conf/flink-conf.yaml"
        echo "high-availability.storageDir: file://${CHECKPOINTDIR}" >> "$FLINK_HOME/conf/flink-conf.yaml"
        echo "state.checkpoints.num-retained: 5" >> "$FLINK_HOME/conf/flink-conf.yaml"
    fi
    # Set Savepoint
    if [[ -z "${SAVEPOINTDIR}" ]]; then
        echo "No savepoint defined"
    else
        echo "state.savepoints.dir: file://${SAVEPOINTDIR}" >> "$FLINK_HOME/conf/flink-conf.yaml"
    fi

    # Update logging
    if [[ -z "${LOGCONFIGDIR}" ]]; then
        echo "Using Flink's default logging"
    else
        cp ${LOGCONFIGDIR}/* $FLINK_HOME/conf/
        echo "Updated logging info"
    fi

    if [[ "${CMD}" = "${TASK_MANAGER}" ]]; then

        echo "Starting Task Manager"
        sed -i -e "s/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: ${TASKMANAGER_SLOTS}/g" "$FLINK_HOME/conf/flink-conf.yaml"
        sed -i -e "s/taskmanager.heap.size: 1024m/taskmanager.heap.size: ${TASKMANAGER_MEMORY}/g" "$FLINK_HOME/conf/flink-conf.yaml"
        echo "taskmanager.host : ${K8S_POD_IP}" >> "$FLINK_HOME/conf/flink-conf.yaml"

        echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
        exec $(drop_privs_cmd) "$FLINK_HOME/bin/taskmanager.sh" start-foreground
    else
        sed -i -e "s/jobmanager.heap.size: 1024m/jobmanager.heap.size: ${JOBMANAGER_MEMORY}/g" "$FLINK_HOME/conf/flink-conf.yaml"

        echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
        if [[ "${CMD}" = "${JOB_MANAGER}" ]]; then
            echo "Starting Job Manager"
            exec $(drop_privs_cmd) "$FLINK_HOME/bin/jobmanager.sh" start-foreground "$@"
        else
            echo "Starting Application"
            exec $(drop_privs_cmd) "$FLINK_HOME/bin/standalone-job.sh" start-foreground --job-classname "$@"
        fi
    fi
fi

exec "$@"
