-- ansible-galaxy to automatically generate the correct folder blueprint.
-- ansible-galaxy role init webserver
-- If you run tree webserver
  tasks/main.yml: The main list of steps the role executes.
  handlers/main.yml: Handlers, such as service restarts.
  templates/: Jinja2 template files (like index.html.j2).
  defaults/main.yml: Default variable values for the role (can be overridden easily).
  vars/main.yml: High-priority variable values for the role.
