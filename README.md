# FDP Flink Build

A small project to build Flink images with built-in support for exporting metrics to Prometheus.

Although there are official Flink images available [here](https://hub.docker.com/_/flink), these images do not contain the `flink-metrics-prometheus.jar` required for [exporting Flink metrics to Prometheus](https://ci.apache.org/projects/flink/flink-docs-stable/monitoring/metrics.html#prometheus-orgapacheflinkmetricsprometheusprometheusreporter). As a result, it is necessary to build custom Flink images adding this required jar

## License

Copyright (C) 2019 Lightbend Inc. (https://www.lightbend.com).

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this project except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
