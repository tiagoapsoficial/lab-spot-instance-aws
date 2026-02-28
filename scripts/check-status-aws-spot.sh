#!/bin/bash

#I used the doc from AWS to generate a script to below:
#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-instance-termination-notices.html
#
#Y heady difficult to get status of spot instance up awaiting return of 200, benching the correct return of instanceof is 404.


# 1. Get Token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")



# 2. Get status code from HTTP
HTTP_CODE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s -o /dev/null -w "%{http_code}" http://169.254.169.254/latest/meta-data/spot/termination-time)



if [ "$HTTP_CODE" -eq 200 ]; then
    TERMINATION_TIME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/spot/termination-time)
    echo "ALERT: This is instace os sleep in : $TERMINATION_TIME"
    # Case necessary executing rsync, backup or script, include below.(ex: aws s3 sync /data s3://my-bucket)
elif [ "$HTTP_CODE" -eq 404 ]; then
    echo "STATUS: Instance OK. Not having interruption scheduled."
else
    echo "STATUS: Error from get status code ->(HTTP $HTTP_CODE)"
fi
