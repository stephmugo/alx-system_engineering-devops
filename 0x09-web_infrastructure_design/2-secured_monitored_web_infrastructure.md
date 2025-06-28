# Secured and Monitored Web Infrastructure for www.foobar.com

This document describes a three-server web infrastructure hosting the website `www.foobar.com`. It builds on a distributed setup with a load balancer (HAProxy), web servers (Nginx), application servers, and a MySQL Primary-Replica cluster. The infrastructure is secured with firewalls and HTTPS, and monitored using data collection clients. The design includes a diagram, explanations of added components, monitoring details, and identified issues.

## Infrastructure Diagram

```
+--------------------+       +---------------------+       +---------------------------------+
| User's Computer    |       | Internet (DNS)      |       | Server 1: Load Balancer        |
|                    |       |                     |       |                                |
|  Browser           |<----->| www.foobar.com      |<----->| +----------------------------+ |
|                    | HTTPS | resolves to LB IP   | HTTPS | | HAProxy (Load Balancer)    | |
+--------------------+       | (A record)          |       | |----------------------------| |
                            +---------------------+       | | SSL Termination (HTTPS)    | |
                                                         | |----------------------------| |
                                                         | | Firewall (e.g., UFW)       | |
                                                         | |----------------------------| |
                                                         | | Monitoring Client (Sumo)   | |
                                                         | +----------------------------+ |
                                                         +---------------------------------+
                                                        /         \
                                                       /           \
                                                      /             \
                                                     /               \
                                                    /                 \
                                                   /                   \
+--------------------------------+                 /                     \                 +--------------------------------+
| Server 2: Web/App/DB Primary   |<---------------/                       \-------------->| Server 3: Web/App/DB Replica   |
|                                |                                                 |                                |
| +----------------------------+ |                                                 | +----------------------------+ |
| | Firewall (e.g., UFW)       | |                                                 | | Firewall (e.g., UFW)       | |
| |----------------------------| |                                                 | |----------------------------| |
| | Nginx (Web Server)         | |                                                 | | Nginx (Web Server)         | |
| |----------------------------| |                                                 | |----------------------------| |
| | Application Server         | |                                                 | | Application Server         | |
| | (e.g., PHP-FPM)            | |                                                 | | (e.g., PHP-FPM)            | |
| |----------------------------| |                                                 | |----------------------------| |
| | Application Files          | |                                                 | | Application Files          | |
| | (Codebase)                 | |                                                 | | (Codebase)                 | |
| |----------------------------| |                                                 | |----------------------------| |
| | MySQL (Database Primary)   | |                                                 | | MySQL (Database Replica)   | |
| |----------------------------| |                                                 | |----------------------------| |
| | Monitoring Client (Sumo)   | |                                                 | | Monitoring Client (Sumo)   | |
| +----------------------------+ |                                                 | +----------------------------+ |
+--------------------------------+                                                 +--------------------------------+
                     |                                                                    |
                     |                                                                    |
                     v                                                                    v
+--------------------------------+                                                 +--------------------------------+
| Server 2: MySQL Primary        |<-------------------Replication---------------->| Server 3: MySQL Replica        |
| +----------------------------+ |                                                 | +----------------------------+ |
| | MySQL (Database Primary)   | |                                                 | | MySQL (Database Replica)   | |
| +----------------------------+ |                                                 | +----------------------------+ |
+--------------------------------+                                                 +--------------------------------+

Flow:
1. User enters www.foobar.com in browser.
2. DNS resolves www.foobar.com to the Load Balancer’s IP (A record).
3. HAProxy (Server 1) terminates SSL (HTTPS) and distributes requests to Server 2 or Server 3 (Nginx) using Round-Robin.
4. Nginx serves static content or forwards dynamic requests to the Application Server (PHP-FPM).
5. Application Server processes code, queries MySQL Primary (Server 2) for writes or Primary/Replica for reads.
6. Response sent back via Nginx and HAProxy to User's Browser.
7. Firewalls on all servers filter traffic; monitoring clients collect and send data to Sumo Logic.
```

## Component Explanations and Additions

### Additional Elements and Their Purpose
1. **3 Firewalls (One on Each Server)**:
   - **Why Added**: Firewalls (e.g., UFW on Linux) are added to Server 1, Server 2, and Server 3 to control incoming and outgoing network traffic. They protect against unauthorized access, DDoS attacks, and other threats by allowing only specific ports (e.g., 443 for HTTPS on Server 1, 80/443 and MySQL ports on Server 2/3).

2. **1 SSL Certificate for HTTPS**:
   - **Why Added**: An SSL certificate is installed on the HAProxy load balancer (Server 1) to enable HTTPS for `www.foobar.com`. It encrypts traffic between the user’s browser and the load balancer, ensuring data confidentiality and integrity.

3. **3 Monitoring Clients (Sumo Logic Data Collectors)**:
   - **Why Added**: Monitoring clients are installed on Server 1, Server 2, and Server 3 to collect performance metrics, logs, and system data. They send this data to Sumo Logic for analysis, enabling proactive detection of issues like high latency, server downtime, or resource exhaustion.

### Specifics About the Infrastructure
1. **What Are Firewalls For?**
   - Firewalls act as a security barrier, filtering network traffic based on predefined rules. They allow legitimate traffic (e.g., HTTPS on port 443) while blocking unauthorized access (e.g., invalid IP addresses or ports). For example, Server 1’s firewall allows port 443 for HTTPS, while Server 2 and Server 3 allow ports for Nginx (80/443) and MySQL replication (3306).

2. **Why Is Traffic Served Over HTTPS?**
   - HTTPS (using an SSL certificate) encrypts data between the user’s browser and the load balancer, protecting sensitive information (e.g., login credentials) from interception or tampering. It also builds user trust and is required for modern web standards and SEO.

3. **What Is Monitoring Used For?**
   - Monitoring tracks the health and performance of servers, services, and applications. It helps detect issues (e.g., high CPU usage, database errors), predict failures, and optimize performance. Sumo Logic provides dashboards and alerts for real-time insights.

4. **How Is the Monitoring Tool Collecting Data?**
   - Sumo Logic data collectors (agents) run on each server, gathering logs (e.g., Nginx access/error logs, MySQL logs), system metrics (CPU, memory, disk usage), and application performance data. These agents send data to Sumo Logic’s cloud platform via secure HTTPS connections for aggregation, analysis, and visualization.

5. **How to Monitor Web Server Queries Per Second (QPS)?**
   - To monitor QPS (Queries Per Second) on the web servers (Nginx on Server 2 and Server 3):
     - Enable Nginx’s access logging to capture request details (e.g., in `/var/log/nginx/access.log`).
     - Configure the Sumo Logic collector to parse Nginx access logs and calculate QPS by counting requests over time intervals (e.g., requests per second).
     - Create a Sumo Logic query (e.g., `_sourceCategory=nginx | timeslice 1s | count by _timeslice`) to aggregate QPS and display it on a dashboard.
     - Set up alerts in Sumo Logic to notify if QPS exceeds thresholds (e.g., indicating a traffic spike or potential DDoS).

## Issues with the Infrastructure

1. **Why Terminating SSL at the Load Balancer Level Is an Issue**:
   - Terminating SSL at HAProxy (Server 1) means traffic between HAProxy and Server 2/Server 3 is unencrypted (HTTP). If an attacker compromises the internal network, they could intercept sensitive data. End-to-end encryption (SSL from HAProxy to Nginx) or re-encryption at HAProxy would mitigate this, but increases complexity.

2. **Why Having Only One MySQL Server Capable of Accepting Writes Is an Issue**:
   - The MySQL Primary (Server 2) is the only server handling write operations. If it fails, no new data can be written (e.g., no user registrations or updates), disrupting functionality. The Replica (Server 3) can serve reads but cannot accept writes, and failover to promote the Replica to Primary requires manual intervention or additional automation.

3. **Why Having Servers with All the Same Components Might Be a Problem**:
   - Server 2 and Server 3 host identical components (Nginx, application server, application files) plus MySQL roles (Primary/Replica). This increases complexity and resource contention, as each server runs multiple services (web, app, database). A failure in one component (e.g., MySQL) could affect others on the same server. Separating roles (e.g., dedicated database servers) would improve isolation and performance but requires more servers.

## Conclusion
This three-server infrastructure enhances security with firewalls and HTTPS, and enables monitoring with Sumo Logic clients. However, SSL termination at the load balancer, a single MySQL Primary, and co-located components introduce risks. Adding a second load balancer, end-to-end encryption, automated database failover, and dedicated server roles would improve reliability and security.