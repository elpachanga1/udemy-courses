# Webserver Role with Handlers

This role demonstrates how **handlers** and **roles** work together in Ansible.

## Role Structure

```
roles/webserver/
├── defaults/
│   └── main.yml          # Default variables
├── tasks/
│   └── main.yml          # Main tasks that notify handlers
├── handlers/
│   └── main.yml          # Handlers triggered by tasks
└── templates/
    ├── apache-config.conf.j2
    └── index.html.j2
```

## How It Works

### 1. **Tasks** (in `tasks/main.yml`)
- Install Apache
- Enable modules
- Copy configuration files
- Each task uses `notify:` to trigger handlers

### 2. **Handlers** (in `handlers/main.yml`)
- `Restart Apache` - Restarts the service
- `Reload Apache` - Reloads configuration
- `Validate Apache Config` - Tests configuration

### 3. **Key Concepts**
- Handlers run **only once** at the end of the play
- Handlers run **only if notified** by a changed task
- Multiple tasks can notify the same handler
- Handlers run in the order they're defined (not the order notified)

## Variables

Defined in `defaults/main.yml`:
- `apache_port: 80` - Apache listening port
- `apache_document_root: /var/www/html` - Document root
- `apache_server_admin: admin@localhost` - Server admin email

## Usage

### Basic execution:
```bash
ansible-playbook with-handlers-and-roles.yml
```

### Override variables:
```bash
ansible-playbook with-handlers-and-roles.yml -e "apache_port=9090"
```

### Check mode (dry run):
```bash
ansible-playbook with-handlers-and-roles.yml --check
```

## Example Output

When you run the playbook:
1. ✅ Apache gets installed → notifies "Restart Apache"
2. ✅ Modules enabled → notifies "Restart Apache" again (but runs only once!)
3. ✅ Config file changed → notifies "Validate Config" + "Restart Apache"
4. 🔄 All handlers run at the end
5. ✅ Post-tasks verify the service

## Benefits of This Approach

- **Organized**: Code is modular and reusable
- **Efficient**: Apache restarts only once, even if multiple tasks change it
- **Safe**: Configuration is validated before restart
- **Flexible**: Variables can be overridden per deployment
