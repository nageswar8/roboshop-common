#!/bin/bash

DOMAIN_NAME="idiap.shop"
HOSTED_ZONE_ID="Z09590552TMQIL7M10P1I"
REGION="us-east-1"

# Get all instances with their IDs, Names, and IPs
aws ec2 describe-instances \
    --region $REGION \
    --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value | [0], PrivateIpAddress, PublicIpAddress, State.Name]' \
    --output text |
while read -r INSTANCE_ID NAME PRIVATE_IP PUBLIC_IP STATE; do
    
    # Skip terminated/stopped instances
    if [[ "$STATE" != "running" ]]; then
        echo "Skipping $NAME ($INSTANCE_ID) as it is $STATE"
        continue
    fi

    # Choose IP: frontend gets Public, others get Private
    if [[ "$NAME" == "frontend" ]]; then
        IP="$PUBLIC_IP"
    else
        IP="$PRIVATE_IP"
    fi

    if [[ -z "$IP" ]]; then
        echo "⚠️ No IP found for $NAME ($INSTANCE_ID), skipping..."
        continue
    fi

    RECORD_NAME="$NAME.$DOMAIN_NAME"

    echo "➡️ Updating Route53: $RECORD_NAME -> $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Creating/updating A record for $NAME\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [{\"Value\": \"$IP\"}]
                }
            }]
        }"

done
