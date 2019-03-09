# FDP Flink Build

A small project to build Flink images. Although there are official Flink
images available [here](https://hub.docker.com/_/flink), these images do not
contain flink-metrics-prometheus jar required for
[exporting Flink metrics to Prometheus](https://ci.apache.org/projects/flink/flink-docs-stable/monitoring/metrics.html#prometheus-orgapacheflinkmetricsprometheusprometheusreporter).
As a result, it is necessary to build custom Flink images adding this required jar

## Building and Publishing the Images

1. Edit the Flink version (currently 1.7.2) in the `ci-build.sh` and all the `Dockerfile*` files.
2. Run `ci-build.sh`. Pass the `--no-push` option if you don't want the built Docker images pushed to the Lightbend repo. (There is also a `--help` option.)

## License

Copyright (C) 2019 Lightbend Inc. (https://www.lightbend.com).

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this project except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
