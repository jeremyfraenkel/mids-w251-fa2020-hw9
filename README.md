# mids-w251-fa2020-hw9
UC-Berkeley MIDS W251 HW9

This repo has my work for HW9. I used bash scripts to setup the instances in as repeatable a way as I could. The scripts assume that you've started up the instances (`aws ec2 run-instances ...`) and then piped the instance json description to a file called `instances.json` (by running something like `aws ec2 describe-instances > instances.json`). The scripts will use `jq` to parse the json, and pull out public DNS names and private IP addresses for the commands they execute later. `setup-all.sh` will run `setup-instance.sh` on each instance, one at a time. That sets up the fstab to mount the efs storage, builds the docker image, modifies docker to allow the nvidia runtime, and launches the openseq2seq container on each instance.

Once all that is done, you should be able to download the data on one instance. `ssh-host.sh` makes it easier to ssh into a given instance just referencing it by index (i.e. `./ssh-host.sh 1` will ssh into the second (zero-based) instance). After that, ideally the `start-training.sh` script should launch the training (it ssh'es into one of the hosts and tries to docker run the training cmd)...it doesn't work quite right at the moment, so I had to do that manually.

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
