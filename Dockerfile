FROM flink:1.7.2-scala_2.11

# Add Prometheus, Table and Queryable state jars. Add additional jars if you need
RUN mv /opt/flink/opt/flink-metrics-prometheus-1.7.2.jar /opt/flink/lib/
RUN mv /opt/flink/opt/flink-queryable-state-runtime_2.11-1.7.2.jar /opt/flink/lib/
RUN mv /opt/flink/opt/flink-table_2.11-1.7.2.jar /opt/flink/lib/

# Update entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh /