#!/bin/sh -e
cd build
# Update images on external web server (downloads.topic.nl)
s3cmd put --acl-public --no-progress artefacts-nv/* s3://topic-downloads/images/
