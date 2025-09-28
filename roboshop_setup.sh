#!/bin/bash

echo "Hello, I came here to automate"

DOMAIN_NAME="idiap.shop"
HOSTED_ZONE_ID="Z09590552TMQIL7M10P1I"

for i in "$@"
do 
    echo "Launching instance for $i..."

    # Create a temporary user-data script for this service
    USER_DATA_FILE=$(mktemp)
    cat > "$USER_DATA_FILE" <<EOF
#!/bin/bash
yum install -y git
cd /home/ec2-user
git clone https://github.com/nageswar8/roboshop-common.git
cd roboshop-common
chmod +x $i.sh
bash $i.sh > /var/log/$i.log 2>&1
EOF

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id ami-09c813fb71547fc4f \
        --instance-type t2.micro \
        --security-group-ids sg-0fecc4fefc0ae3b31 \
        --region us-east-1 \
        --user-data "file://$USER_DATA_FILE" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    rm -f "$USER_DATA_FILE"

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    if [ "$i" != "frontend" ]; then 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)
    fi

    RECORD_NAME="$i.$DOMAIN_NAME"
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
                    \"TTL\": 2,
                    \"ResourceRecords\": [{\"Value\": \"$IP\"}]
                }
            }]
        }"
done
