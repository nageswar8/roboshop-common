#!/bin/bash

echo "Hello, I came here to automate"

DOMAIN_NAME="idiap.shop"
HOSTED_ZONE_ID="Z09590552TMQIL7M10P1I"

for i in "$@"
do 
    echo "Launching instance for $i..."

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id ami-09c813fb71547fc4f \
        --instance-type t2.micro \
        --security-group-ids sg-0fecc4fefc0ae3b31 \
        --region us-east-1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    if [ "$i" != "frontend" ]; then 
        # Private IP for non-frontend
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)

        RECORD_NAME="$i.$DOMAIN_NAME"
    else
        # Public IP for frontend
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)

        RECORD_NAME="$i.$DOMAIN_NAME"
    fi

    echo "Updating Route53: $RECORD_NAME -> $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Creating an A record\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 60,
                    \"ResourceRecords\": [{\"Value\": \"$IP\"}]
                }
            }]
        }"
done
