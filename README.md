# mids-w251-fa2020-hw9
UC-Berkeley MIDS W251 HW9

This repo has my work for HW9. I used bash scripts to setup the instances in as repeatable a way as I could. The scripts assume that you've started up the instances (`aws ec2 run-instances ...`) and then piped the instance json description to a file called `instances.json` (by running something like `aws ec2 describe-instances > instances.json`). The scripts will use `jq` to parse the json, and pull out public DNS names and private IP addresses for the commands they execute later. `setup-all.sh` will run `setup-instance.sh` on each instance, one at a time. That sets up the fstab to mount the efs storage, builds the docker image, modifies docker to allow the nvidia runtime, and launches the openseq2seq container on each instance.

Once all that is done, you should be able to download the data on one instance. `ssh-host.sh` makes it easier to ssh into a given instance just referencing it by index (i.e. `./ssh-host.sh 1` will ssh into the second (zero-based) instance). After that, ideally the `start-training.sh` script should launch the training (it ssh'es into one of the hosts and tries to docker run the training cmd)...it doesn't work quite right at the moment, so I had to do that manually.

### Questions

* How long does it take to complete the training run? (hint: this session is on distributed training, so it will take a while)
> It took roughly 36hrs to train 100k steps.

* Do you think your model is fully trained? How can you tell?
> I can see that in the examples with the 300k step training that BLUE score and eval loss continue improving significantly after the 100k step mark, so it seems like I could continue training and improve the model. However, we have made it past the initial big improvements, and improvements after 100k are slowing down.

* Were you overfitting?
> The training loss after 100k steps was ~1.67 and eval loss was ~1.6, so I don't think the model was overfitting particularly badly.

* Were your GPUs fully utilized?
> Yes, I used `nvidia-smi` to check GPU utilization throughout the process, and they were 100% utilized.

* Did you monitor network traffic (hint: apt install nmon ) ? Was network the bottleneck?
> I used the AWS console network graphs, and see that we maxed out at about 17.3GB/5min on each instance, both in and out.

* Take a look at the plot of the learning rate and then check the config file. Can you explan this setting?
The config looks like this:

```
 "lr_policy": transformer_policy,
  "lr_policy_params": {
    "learning_rate": 2.0,
    "warmup_steps": 8000,
    "d_model": d_model,
  },
```
The initial increase is the `warmup` that's referenced here, and then it decays exponentially after that. The code for openseq2seq says that the strategy came from this paper (https://arxiv.org/pdf/1706.03762.pdf), where they explain:

>5.3    OptimizerWe used the Adam optimizer [20] with β1= 0.9, β2= 0.98 and= 10−9. We varied the learningrate over the course of training, according to the formula:
>
>       lrate=d^(−0.5)·min(step_num^(−0.5),step_num·warmup_steps^(−1.5))                                                (3)
>
>This corresponds to increasing the learning rate linearly for the first `warmup_steps` training steps, and decreasing it thereafter proportionally to the inverse square root of the step number. We used `warmup_steps= 4000`

* How big was your training set (mb)? How many training lines did it contain?

There were two files (source and target) involved in training:

```
-rw-r--r-- 1 root root 976M Oct 15 17:59 train.clean.de.shuffled.BPE_common.32K.tok
-rw-r--r-- 1 root root 915M Oct 15 17:59 train.clean.en.shuffled.BPE_common.32K.tok
```

For a total of approximately 1.89GB. Each file has 4524868 lines.

* What are the files that a TF checkpoint is comprised of?

A `.index` file, a `.meta` file and a `.data` file.

* How big is your resulting model checkpoint (mb)?

It's a little over 700MB total, with the data file being ~690MB.

* Remember the definition of a "step". How long did an average step take?

We generally did about 0.78 steps/sec, so each step took approximately 1.28 seconds.

* How does that correlate with the observed network utilization between nodes?

It's not super obvious to me what the correlation is...the AWS network monitoring suggests each node is writing about approximately as fast as it's reading it, roughly 17.3GB per 5 minute period. That's roughly 58M/B per second, which would mean we brought 74MB over per node per step, and wrote out a similar amount. I do not know how that number relates to any of the data files though.

_________________

### Below are notes I took when setting up my instances. Totally ignorable...

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
