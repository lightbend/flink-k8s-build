FROM flink:1.7.2-scala_2.11

# Add Prometheus, Table and Queryable state jars. Add additional jars if you need
RUN mv /opt/flink/opt/flink-metrics-prometheus-1.7.2.jar /opt/flink/lib/
RUN mv /opt/flink/opt/flink-queryable-state-runtime_2.11-1.7.2.jar /opt/flink/lib/
RUN mv /opt/flink/opt/flink-table_2.11-1.7.2.jar /opt/flink/lib/

# Add Prometheus metric reporter to config
RUN echo "metrics.reporters: prom" >> "/opt/flink/conf/flink-conf.yaml"
RUN echo "metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter" >> "/opt/flink/conf/flink-conf.yaml"
RUN echo "metrics.reporter.prom.port: 9249" >>  "/opt/flink/conf/flink-conf.yaml"


# Add write permissions to the directories
RUN chmod -R 777 /opt/flink/log
RUN chmod -R 777 /opt/flink/conf

# Update entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh /