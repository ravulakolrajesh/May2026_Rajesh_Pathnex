# Deploy to Dev for the CPI Team (Loads env_dev.yml variables automatically)
  ansible-playbook -i aws_ec2.yml playbook.yml --limit "team_cpi:&env_dev" --private-key=~/.ssh/dev-key.pem

# Deploy to Prod for the MHUB Team (Loads env_prod.yml variables automatically)
  ansible-playbook -i aws_ec2.yml playbook.yml --limit "team_mhub:&env_prod" --private-key=~/.ssh/prod-key.pem
