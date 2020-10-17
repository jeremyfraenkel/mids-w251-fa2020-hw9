# mids-w251-fa2020-hw9
UC-Berkeley MIDS W251 HW9

```
jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$ aws ec2 describe-vpcs | grep VpcId
            "VpcId": "vpc-0a309d61",
jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$aws ec2 create-security-group --group-name hw09 --description "HW09" --vpc-id vpc-0a309d61
{
    "GroupId": "sg-05c2b86a725a62100"
}

```

NVIDIA Deep Learning AMI: ami-0bc1398a752880427

aws ec2 run-instances --image-id ami-0bc1398a752880427 --instance-type g4dn.2xlarge --security-group-ids sg-05c2b86a725a62100  --associate-public-ip-address --key-name w251hw3 --count 4 

jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$ aws ec2 describe-instances > instances.json

aws ec2 authorize-security-group-ingress --group-id  sg-05c2b86a725a62100  --protocol tcp --port 1-65535 --cidr 0.0.0.0/0

jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$ aws efs create-file-system --region us-east-2
{
    "OwnerId": "387946532044",
    "CreationToken": "02605466-d8aa-424f-a56f-e7eafad514ad",
    "FileSystemId": "fs-e4891b9c",
    "FileSystemArn": "arn:aws:elasticfilesystem:us-east-2:387946532044:file-system/fs-e4891b9c",
    "CreationTime": "2020-10-15T10:08:34-05:00",
    "LifeCycleState": "creating",
    "NumberOfMountTargets": 0,
    "SizeInBytes": {
        "Value": 0,
        "ValueInIA": 0,
        "ValueInStandard": 0
    },
    "PerformanceMode": "generalPurpose",
    "Encrypted": false,
    "ThroughputMode": "bursting",
    "Tags": []
}

jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$ aws ec2 describe-subnets
{
    "Subnets": [
        {
            "AvailabilityZone": "us-east-2a",
            "AvailabilityZoneId": "use2-az1",
            "AvailableIpAddressCount": 4091,
            "CidrBlock": "172.31.0.0/20",
            "DefaultForAz": true,
            "MapPublicIpOnLaunch": true,
{
    "Subnets": [
        {
            "AvailabilityZone": "us-east-2a",
            "AvailabilityZoneId": "use2-az1",
            "AvailableIpAddressCount": 4091,
            "CidrBlock": "172.31.0.0/20",
            "DefaultForAz": true,
            "MapPublicIpOnLaunch": true,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-03a17568",
            "VpcId": "vpc-0a309d61",
            "OwnerId": "387946532044",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "SubnetArn": "arn:aws:ec2:us-east-2:387946532044:subnet/subnet-03a17568"
        },
        {
            "AvailabilityZone": "us-east-2b",
            "AvailabilityZoneId": "use2-az2",
            "AvailableIpAddressCount": 4091,
            "CidrBlock": "172.31.16.0/20",
            "DefaultForAz": true,
            "MapPublicIpOnLaunch": true,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-751e1c0f",
            "VpcId": "vpc-0a309d61",
            "OwnerId": "387946532044",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "SubnetArn": "arn:aws:ec2:us-east-2:387946532044:subnet/subnet-751e1c0f"
        },
        {
            "AvailabilityZone": "us-east-2c",
            "AvailabilityZoneId": "use2-az3",
            "AvailableIpAddressCount": 4087,
            "CidrBlock": "172.31.32.0/20",
            "DefaultForAz": true,
            "MapPublicIpOnLaunch": true,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",


aws efs create-mount-target --file-system-id fs-e4891b9c --subnet-id subnet-6298f22e --security-group sg-05c2b86a725a62100 --region us-east-02

jtrobec@jtrobec-xavier-01:~/workspace/mids-w251-fa2020-hw9$ aws efs create-mount-target --file-system-id fs-e4891b9c --subnet-id subnet-6298f22e --security-group sg-05c2b86a725a62100 --region us-east-2
{
    "OwnerId": "387946532044",
    "MountTargetId": "fsmt-7740180e",
    "FileSystemId": "fs-e4891b9c",
    "SubnetId": "subnet-6298f22e",
    "LifeCycleState": "creating",
    "IpAddress": "172.31.32.82",
    "NetworkInterfaceId": "eni-052819b5cd0139b1d",
    "AvailabilityZoneId": "use2-az3",
    "AvailabilityZoneName": "us-east-2c",
    "VpcId": "vpc-0a309d61"
}
