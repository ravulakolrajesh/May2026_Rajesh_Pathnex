# Dynamic inventories eliminate the need to manually maintain a static list of IP addresses in an inventory.ini file. Ansible queries AWS API — in real-time to discover the servers based on live attributes like tags, 
instance states, or regions. aws_ec2 plugin can dynamically track your AWS EC2 infra.

# STEP1: Installing Required Dependencies. AWS Plugin requires Python boto3 library to communicate with AWS API.
  pip install boto3
  ansible-galaxy collection install amazon.aws

# STEP2: Step 2: Enable the Plugin by creating the ansible.cfg file
# STEP3: Create the Dynamic Inventory Configuration: The configuration file must end with aws_ec2.yml or aws_ec2.yaml for the plugin to recognize it. 
  Create a file named my_aws_ec2.yml and add this configuration
# Step4: Verify Your Live Infrastructure
  ansible-inventory --graph
# Step5: Run Playbooks Against Dynamic Groups: delete any inventory.ini file if exists. target groups are determined strictly by your live AWS tags.
