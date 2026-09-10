# A Secure AWS Network Infrastructure Project
This is a terraform-provisioned AWS aritecture project, that promotes VPC with least-privilege security groups and remote state management in order to
have a private and secure network to operate in.

## The Business Problem
A local business wanted to have a private and secure network where its sensitive workload was never directly exposed to the public internet, and only reachable through a controlled entry point from an authorized source. They wanted to ensure that this infrastructure is actually deployable and replicable across environments like dev, staging, and prod if needed so. They wanted a Cloud Infrastructure with a consistent and protected environment without needing to go to the console, in order to avoid manual errors.


## Architecture
![Architecture Diagram](<docs/Secure AWS Network Infrastructure.drawio.png>)


## Key Decisions


### Decision 1: User managed encryption through KMS instead the the default S3 encryption
I decided to choose the more complex and costtly design for key storage since I valued more on the experience of usaging the KMS service 
for the keys storage. But more importantly, I had choosen due to the service allowability to rotate and lifecycle on the keys, which would only
increase the security and safety for the network.


### Decision 2: Having the private keys not being copied but insteead SSH agent to the bastion
It would been a easier, simplier and straightforward design to instead copy the private key onto the bastion which 
would then allow me to use the same key to hop on to the private instance, but the main focus on security, it would be unsafe to copy 
outside my own drive of the key. So, in other to continue in using the best security practice, I instead used the SSH agent forwarding, which would 
allow me to hop through the bastion without in any way expose the key itself. But as well, the private key is never kept or being touch in the bastion's disk


## Deploy Steps

### Prerequsites
- You need terraform
- AWS Account
- Money

### Steps
1. Clone the repo
2. Create and configure a tfvars to assigned the variables paramaters to all the different needed modules variables
3. Init the bootstrap dir
4. Init the infrastructure dir
5. Plan the bootstrap
6. Apply the bootstrap
7. Plan the infrastructure
8. Apply the infrastructure
9. SSH into the bastion ec2, and then SSH into the private EC2


### Cleanup
- Destory the infrasturcture first
- Destory the bootstrap second

---