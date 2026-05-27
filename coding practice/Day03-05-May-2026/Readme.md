-- ansible-galaxy to automatically generate the correct folder blueprint. 
-- ansible-galaxy role init webserver 
-- If you run tree webserver tasks/main.yml: The main list of steps the role executes. 
  handlers/main.yml: Handlers, such as service restarts. 
  templates/: Jinja2 template files (like index.html.j2). 
  defaults/main.yml: Default variable values for the role (can be overridden easily). 
  vars/main.yml: High-priority variable values for the role.

# the above created role is referred in the main playbook
  ansible-playbook -i inventory.ini site.yml

Pre-Built Community ROLEs: Ansible Galaxy is the official public repository for community-built Ansible roles.
  ansible-galaxy search security
  # By default, Ansible installs this into your global directory (usually ~/.ansible/roles/)
  ansible-galaxy role install geerlingguy.git

  ansible-galaxy role list
  ansible-playbook -i inventory.ini deploy_tools.yml

# Instead of downloading the Pre-built roles manually we can do it using a requirements.yml
  ansible-galaxy role install -r requirements.yml
