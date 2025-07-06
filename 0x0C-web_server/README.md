# 0x0C. Web Server

This project is part of the **ALX System Engineering & DevOps** curriculum. The goal is to understand the basics of web servers, configure them using Bash and Puppet, manage domain names, set up custom error pages, redirections, and automation using configuration management tools like Puppet.

---

## 🛠️ Technologies & Environment

- OS: Ubuntu 16.04 LTS
- Nginx: Web server used
- Puppet: For configuration management
- Shell scripts: Written in `bash`
- Editors: `vi`, `vim`, `emacs`
- All Bash scripts must be executable and pass Shellcheck 0.3.7

---

## 📁 Project Structure

| File                                | Description                                                                 |
|-------------------------------------|-----------------------------------------------------------------------------|
| `0-transfer_file`                   | Bash script to transfer a file to a server using `scp`                     |
| `1-install_nginx_web_server`        | Bash script to install and configure Nginx on Ubuntu                       |
| `2-setup_a_domain_name`            | File containing a registered `.tech` domain name                           |
| `3-redirection`                     | Bash script that configures a `/redirect_me` 301 redirect in Nginx        |
| `4-not_found_page_404`             | Bash script to configure a custom 404 page in Nginx                        |
| `7-puppet_install_nginx_web_server.pp` | Puppet manifest to install and configure Nginx with root and redirect setup |

---

## 📌 Tasks

### 0. Transfer a File to Your Server

**Script:** `0-transfer_file`

Transfers a specified file to the home directory of a remote server via `scp`, using a provided SSH key.

**Usage:**

```bash
./0-transfer_file PATH_TO_FILE IP USERNAME PATH_TO_SSH_KEY
```

---

### 1. Install Nginx Web Server

**Script:** `1-install_nginx_web_server`

Installs Nginx and sets up the default web page to return:

```
Hello World!
```

---

### 2. Setup a Domain Name

**File:** `2-setup_a_domain_name`

Contains a single line: the root domain name registered via `.TECH` (e.g., `mywebsite.tech`), which is configured to point to the server’s public IP via an A record.

---

### 3. Redirection

**Script:** `3-redirection`

Configures Nginx to redirect requests from `/redirect_me` to:

```
https://www.youtube.com/watch?v=QH2-TGUlwu4
```

Returns a `301 Moved Permanently`.

---

### 4. Not Found Page 404

**Script:** `4-not_found_page_404`

Creates a custom Nginx 404 error page returning:

```
Ceci n'est pas une page
```

Returns proper HTTP `404` status code.

---

### 5. Install Nginx Using Puppet

**Manifest:** `7-puppet_install_nginx_web_server.pp`

Uses Puppet to:
- Install and start Nginx
- Set the root page to display `"Hello World!"`
- Add a 301 redirect from `/redirect_me` to the YouTube link

---

## 🔍 Testing Tips

- Use `curl` to test redirection and custom error pages:

```bash
curl -sI http://yourserverip/redirect_me
curl http://yourserverip/nonexistent
```

- To check DNS propagation for your `.tech` domain:

```bash
dig yourdomain.tech
```

---
