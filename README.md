# Jenkins for Release Engineering

This is a Jenkins Docker build for the RS release engineering team. It includes all of our favorite plugins with some
startup configuration. This repository also includes the Helm chart and templates to deploy Jenkins into a Kubernetes
cluster.

## Dependencies

To build and run Jenkins for Release Engineering, the following software packages must be installed.

* `docker` - to build, publish and deploy Jenkins
* `helm` - to deploy to kubernetes
* `bash` - to run the helper scripts
* `wget` - to test/validate remote plugins

## Version Info

The docker tag/version information is in a single `versions.sh` file. This file is loaded by the helper scripts to
build, publish, and run the docker image.

## Validating Plugins

Jenkins will validate the plugins when it tries to build the docker image.
Further testing is done when the image runs at startup. However, if you want
to quickly test to ensure the plugin and versions are available on the
Jenkins Plugin Update Center server, you can simply run the
`validate-plugin-exists.sh` script. This is handy if you simply want to
validate that the plugin name and version number exist and are valid. It may
save some time if you are adding/shuffling around plugins.

## Docker Image

The Release Engineering team Jenkins image is based on the 
[official Jenkins image](https://github.com/jenkinsci/docker/blob/master/Dockerfile-alpine) which is based on Alpine OS.

## Manual Image Building

To manually build the image for testing, run the `build-image.sh` script:

```bash
./build-image.sh
```

> Note: building the docker image takes some time as the plugins are
downloaded from [the Jenkins Plugin repository](https://plugins.jenkins.io)
and loaded into the docker image.

## Manual Image Publish

To manually publish the docker image for testing, first build the image and
then run the `publish-image.sh` script:

```bash
./publish-image.sh
```

> Note: this script basically runs `docker push` which requires you to
previously log into hub.docker.com via `docker login`.

## Local Testing

To run the docker image for local testing, first build the image and then run
the `run.sh` script:

```bash
./run.sh
```

## Deploy Image to OpenShift

For OpenShift, it seems you need to specify an Image Stream to load images from external sources.  To create the Image
Stream, [log into the OpenShift Console](https://rsi.rackspace.net/console) then from the menu, select 
"Add To Project" -> "Deploy Image". Select the Image Name radio button and fill out the remote image tag details, such
as `dealako/re-jenkins:0.0.2`. Press the search button beside the image name to fetch the meta-data.  Review the meta-
data, add any environment variables, add any other labels or tags, and press "Create".

## Deploying to OpenShift

To deploy the helm chart to OpenShift:

```bash
# Setup
export TILLER_NAMESPACE=rpc-re
cd deployment/charts/jenkins-master
# Test
helm lint
helm install --debug --namespace rpc-re --name jenkins-master --dry-run .
# Deploy
helm install --debug --namespace rpc-re --name jenkins-master .
```

Review the resources in the console or run a watch on the OpenShift resources, such as:

```bash
watch -n 5 -c "oc get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pv,pvc -o wide --namespace rpc-re"
```

## OpenShift Route

TODO: add notes

## Extracting Existing Plugins

The Dockerfile leverages the `plugins/plugins.txt` file to determine which
plugins to load into the Jenkins server at docker image build time. Simply
add the desired plugin and version into this file (one plugin per line). As a
starting point you may want to extract a plugin list from a running Jenkins
server. To do this, use the Jenkins API to dump the values (replace
`YOUR_USERNAME` and `YOUR_PASSWORD` below with your credentials):

```bash
echo 'script=Jenkins.instance.pluginManager.plugins.each{ plugin -> println("${plugin.getShortName() }:${plugin.getVersion()}") }' | no_proxy=localhost curl --user YOUR_USERNAME:YOUR_PASSWORD --netrc --silent --data-binary @- -X POST "https://rpc.jenkins.cit.rackspace.net/scriptText" | sort > plugins.txt
```

To figure out the latest plugin versions, [view the plugins on
jenkins.io](https://plugins.jenkins.io/). Another way is to simply startup
the docker image and from the Jenkins UI navigate to the Plugin Update page.
It will show which plugins require updates (and the associated versions).

[Reference]( https://stackoverflow.com/questions/9815273/how-to-get-a-list-of-installed-jenkins-plugins-with-name-and-version-pair/35292719#35292719)

## CI/CD

A placeholder `Jenkinsfile` was added to this repository. We'll update it soon
so that future releases of the Jenkins master will be driven by code changes.

## TODO

* Upgrade Jenkins from version 2.107.1 to version 2.121.2
* Setup security
