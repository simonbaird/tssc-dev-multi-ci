# tssc-dev-multi-ci test

This contains bash scripting to automate a test of the different pipelines.

Currently it's run manually by a human, but the longer term goal is to be able to run it automatically and use it as a pre-merge CI test.

A rough outline of what the testing does:

* Prepare a sample git repo
* Set/update secrets in the sample repo (based on local env vars)
* Add the latest pipeline definition from this repo
* Update the rhtap/env.sh file in the sample repo
* Create a commit in the sample repo and push it to main branch

The pushing of the commit is expected to trigger the pipeline, which you can then go examine manually to confirm it worked as expected.

It currently supports Jenkins, GitLab and GitHub pipelines.
