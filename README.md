# GoodRX Coding Sample

To build and deploy the code in this repository, run the `build.sh` script and pass along an argument to a publicly-facing Docker registry which you have write-access to : 
```
./build.sh <path_to_public_registry>
```
The default Docker image for this project in Terraform is `waltisfrozen/sample-project-goodrx`, which is built through a webhook between this repo and the Docker Hub. If no image is specified, the Docker build steps are skipped and that image is used instead. 

For the Terraform stages, an ssh keypair is created in the /terraform directory, which is used when building an EC2 instance to host the web app. After Terraform has been run, you should be able to validate the app with the following curl command (note the fixed json payload):
```
curl -H 'Content-Type: application/json' -X POST -d '{"jobs":{"Build base AMI":{"Builds":[{"runtime_seconds":"1931","build_date":"1506741166","result":"SUCCESS","output":"base-ami us-west-2 ami-9f0ae4e5 d1541c88258ccb3ee565fa1d2322e04cdc5a1fda"},{"runtime_seconds":"1825","build_date":"1506740166","result":"SUCCESS","output":"base-ami us-west-2 ami-d3b92a92 3dd2e093fc75f0e903a4fd25240c89dd17c75d66"},{"runtime_seconds":"126","build_date":"1506240166","result":"FAILURE","output":"base-ami us-west-2 ami-38a2b9c1 936c7725e69855f3c259c117173782f8c1e42d9a"},{"runtime_seconds":"1842","build_date":"1506240566","result":"SUCCESS","output":"base-ami us-west-2 ami-91a42ed5 936c7725e69855f3c259c117173782f8c1e42d9a"},{"runtime_seconds":"5","build_date":"1506250561"},{"runtime_seconds":"215","build_date":"1506250826","result":"FAILURE","output":"base-ami us-west-2 ami-34a42e15 936c7725e69855f3c259c117173782f8c1e42d9a"}]}}}' goodrx-dev-814850301.us-west-2.elb.amazonaws.com/builds
```
This webapp only has two endpoints, `/builds` which only accepts HTTP POST requests and `/status` which returns a 200 response on HTTP GETs for the ELB health check. 
