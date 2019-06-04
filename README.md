# FDP Flink Build

A small project to build Flink images. Although there are official Flink
images available [here](https://hub.docker.com/_/flink), these images do not
contain flink-metrics-prometheus jar required for
[exporting Flink metrics to Prometheus](https://ci.apache.org/projects/flink/flink-docs-stable/monitoring/metrics.html#prometheus-orgapacheflinkmetricsprometheusprometheusreporter).
As a result, it is necessary to build custom Flink images adding this required jar

## Added HA implementation for PVC

In the current Flink implementation, HA support can be implemented either using Zookeeper or Custom Factory class.
This implementation adds HA implementation based on PVC. The idea behind this implementation
is as follows:
* Because implementation assumes a single instance of Job manager (Job manager selection and restarts are done by K8 Deployment of 1)
URL management is done using StandaloneHaServices implementation (in the case of cluster) and EmbeddedHaServices implementation (in the case of mini cluster)
* For management of the submitted Job Graphs, checkpoint counter and completed checkpoint an implementation is leveraging the following file system layout
````
 ha									-----> root of the HA data
  checkpointcounter					-----> checkpoint counter folder
  	<job ID>						-----> job id folder
  		<counter file>				-----> counter file
  	<another job ID>				-----> another job id folder
  ...........
  completedCheckpoint				-----> completed checkpoint folder
 	<job ID>						-----> job id folder
  		<checkpoint file>			-----> checkpoint file
  		<another checkpoint file>	-----> checkpoint file
 		...........
  		<another job ID>			-----> another job id folder
  ...........
  submittedJobGraph				    -----> submitted graph folder
  	<job ID>						-----> job id folder
  		<graph file>				-----> graph file
  	<another job ID>				-----> another job id folder
  ...........
````

An implementation overwrites 2 of the Flink files:
* HighAvailabilityServicesUtils - added `FILESYSTEM` option for picking HA service
* HighAvailabilityMode - added `FILESYSTEM` to available HA options.

The actual implementation exists of the following classes:
* `FileSystemHAServices` - an implementation of a `HighAvailabilityServices` for file system
* `FileSystemUtils` - support class for creation of runtime components.
* `FileSystemStorageHelper` - file system operations implementation for filesystem based HA
* `FileSystemCheckpointRecoveryFactory` - an implementation of a `CheckpointRecoveryFactory`for file system
* `FileSystemCheckpointIDCounter` - an implementation of a `CheckpointIDCounter` for file system
* `FileSystemCompletedCheckpointStore` - an implementation of a `CompletedCheckpointStore` for file system
* `FileSystemSubmittedJobGraphStore` - an implementation of a `SubmittedJobGraphStore` for file system

## Testing

Here we are using Flink's native leader election, which is fully tested by Flink. We also implement 
Flink interfaces, so connectivity between pieces is also tested by Flink.

## Building and Publishing the Images

1. Edit the Flink version (currently 1.8.0) in the `ci-build.sh`.
2. Run `ci-build.sh`.

## License

Copyright (C) 2019 Lightbend Inc. (https://www.lightbend.com).

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this project except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
