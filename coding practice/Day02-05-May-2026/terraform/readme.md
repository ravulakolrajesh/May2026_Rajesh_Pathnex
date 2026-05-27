-- used SSH keygen to create a local key files
-- chmod 400 ~/.ssh/private key file name
-- used the local public key in the create ec2 file for attaching it to the EC2 that we are creating.
-- if we are attaching the public key while creating the EC2 we can use the private key of the public key to connect to the EC2
-- this creates the same private in AWS key pairs.
-- i.e. local ~/.ssh/privatekey == AWS key pairs pem file
alternatively
we can create a key pair in AWS and download it for connecting to the EC2.

-- there is a difference AWS Configure and SSH.
AWS Configure is used to connect to AWS while SSH is used to connect to EC2 instances with private key
