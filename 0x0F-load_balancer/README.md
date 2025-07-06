# 0x0F. Load balancer

## Background Context

We are improving our web infrastructure to add redundancy and handle more traffic by introducing load balancing. This project sets up:

- Two web servers with custom Nginx HTTP headers.
- A load balancer using HAProxy with round-robin distribution.
- Puppet automation for configuration consistency.

---

## Tasks

### Task 0. Double the number of webservers

**Script:** `0-custom_http_response_header`  
**Description:** Configures Nginx on a fresh Ubuntu 16.04 server to add a custom HTTP response header `X-Served-By` containing the server's hostname.

#### Example usage:

```bash
curl -sI <WEB_SERVER_IP> | grep X-Served-By
```

**Expected Output:**

```
X-Served-By: [HOSTNAME]
```

---

### Task 1. Install your load balancer

**Script:** `1-install_load_balancer`  
**Description:** Installs and configures HAProxy on `lb-01` to distribute traffic to `web-01` and `web-02` using a round-robin algorithm.

> Make sure to replace `<WEB_01_PRIVATE_IP>` and `<WEB_02_PRIVATE_IP>` with the actual private IP addresses of the web servers.

---

### Task 2. Add a custom HTTP header with Puppet

**File:** `2-puppet_custom_http_response_header.pp`  
**Description:** Puppet manifest that ensures Nginx is installed and configured to return a custom `X-Served-By` header with the server's hostname.

---

## Requirements

- Ubuntu 16.04 LTS
- Bash scripts must start with:
  ```bash
  #!/usr/bin/env bash
  # Description of script
  ```
- Puppet manifest must be idempotent and use proper resource declarations.
- All scripts must be executable and pass Shellcheck (ignore SC2154).

---
