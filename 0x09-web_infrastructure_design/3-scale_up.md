# Scaled-Up Web Infrastructure for www.foobar.com

This document describes a five-server web infrastructure hosting `www.foobar.com`, designed for scalability, security, and monitoring. It builds on the previous three-server setup by adding two servers (one for the load balancer cluster, one for component splitting), a second HAProxy load balancer in a cluster, and splitting components (web server, application server, database) onto dedicated servers. Apache is used exclusively as the web server for consistency. The infrastructure includes firewalls, HTTPS via an SSL certificate, and Sumo Logic monitoring.

## Infrastructure Diagram

```
+--------------------+       +---------------------+       +---------------------------------+
| User's Computer    |       | Internet (DNS)      |       | Server 1: Load Balancer (LB1)  |
|                    |       |                     |       |                                |
|  Browser           |<----->| www.foobar.com      |<----->| +----------------------------+ |
|                    | HTTPS | resolves to VIP     | HTTPS | | HAProxy (Primary LB)       | |
+--------------------+       | (A record)          |       | |----------------------------| |
                            +---------------------+       | | SSL Termination (HTTPS)    | |
                                                         | |----------------------------| |
                                                         | | Firewall (e.g., UFW)       | |
                                                         | |----------------------------| |
                                                         | | Monitoring Client (Sumo)   | |
                                                         | +----------------------------+ |
                                                         +---------------------------------+
                                                                   |
                                                                   | Keepalived (Virtual IP)
                                                                   |
                                                         +---------------------------------+
                                                         | Server 2: Load Balancer (LB2)  |
                                                         |                                |
                                                         | +----------------------------+ |
                                                         | | HAProxy (Backup LB)        | |
                                                         | |----------------------------| |
                                                         | | SSL Termination (HTTPS)    | |
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
+--------------------------------+                 /                   \                 +--------------------------------+
| Server 3: Web Server           |<---------------/                     \-------------->| Server 4: Application Server   |
|                                |                                                 |                                |
| +----------------------------+ |                                                 | +----------------------------+ |
| | Firewall (e.g., UFW)       | |                                                 | | Firewall (e.g., UFW)       | |
| |----------------------------| |                                                 | |----------------------------| |
| | Apache (Web Server)        | |                                                 | | PHP-FPM (App Server)       | |
| |----------------------------| |                                                 | |----------------------------| |
| | Monitoring Client (Sumo)   | |                                                 | | Application Files          | |
| +----------------------------+ |                                                 | | (Codebase)                 | |
+--------------------------------+                                                 | |----------------------------| |
                                                                          | | Monitoring Client (Sumo)   | |
                                                                          | +----------------------------+ |
                                                                          +--------------------------------+
                                                                                     |
                                                                                     |
                                                                                     v
                                                                          +--------------------------------+
                                                                          | Server 5: Database             |
                                                                          |                                |
                                                                          | +----------------------------+ |
                                                                          | | Firewall (e.g., UFW)       | |
                                                                          | |----------------------------| |
                                                                          | | MySQL (Primary)            | |
                                                                          | |----------------------------| |
                                                                          | | MySQL (Replica)            | |
                                                                          | |----------------------------| |
                                                                          | | Monitoring Client (Sumo)   | |
                                                                          | +----------------------------+ |
                                                                          +--------------------------------+

Flow:
1. User enters www.foobar.com in browser.
2. DNS resolves www.foobar.com to the Virtual IP (VIP) shared by the HAProxy cluster (Server 1 primary, Server 2 backup).
3. HAProxy (Server 1 or 2) terminates SSL (HTTPS) and forwards requests to Server 3 (Apache) using Round-Robin.
4. Apache serves static content or forwards dynamic requests to Server 4 (PHP-FPM).
5. PHP-FPM processes code, querying MySQL Primary or Replica on Server 5.
6. Response sent back via Apache and HAProxy to User's Browser.
7. Firewalls filter traffic; monitoring clients send data to Sumo Logic.
```

## Component Explanations and Additions

### Previous Components (Retained and Adjusted)
- **Server 1 (HAProxy)**: Primary load balancer with SSL termination, firewall, and Sumo Logic client.
- **Server 3 (Apache)**: Dedicated to the web server role using Apache (previously Server 2 in the three-server setup, reassigned for clarity), with firewall and Sumo Logic client.
- **Firewalls**: On all servers to filter traffic (e.g., port 443 on Server 1/2, 80/443 on Server 3, application ports on Server 4, 3306 on Server 5).
- **SSL Certificate**: On HAProxy (Server 1 and 2) for HTTPS, encrypting traffic from browser to load balancer.
- **Monitoring Clients**: Sumo Logic agents on all servers to collect logs and metrics (e.g., Apache access logs on Server 3 for QPS monitoring).

### Additional Elements and Their Purpose
1. **2 Servers (Server 4 and Server 5)**:
   - **Why Added**: 
     - **Server 4 (Application Server)**: Dedicated to PHP-FPM and the application files (codebase), isolating application logic from web and database tasks. This improves performance by preventing resource contention and enables independent scaling of application resources.
     - **Server 5 (Database)**: Dedicated to MySQL Primary and Replica, isolating database operations from web and application tasks. This enhances database performance and scalability, maintaining the Primary-Replica cluster for read/write efficiency.

2. **1 Load Balancer (HAProxy on Server 2, Configured as Cluster)**:
   - **Why Added**: Server 2 hosts a second HAProxy instance, forming an Active-Passive cluster with Server 1 using Keepalived and a shared Virtual IP (VIP). This eliminates the load balancer single point of failure (SPOF), ensuring high availability. If Server 1 fails, Server 2 takes over, maintaining HTTPS traffic flow. Both HAProxy instances have the SSL certificate.

3. **Split Components (Web Server, Application Server, Database)**:
   - **Why Added**: Splitting components onto dedicated servers optimizes performance, scalability, and fault isolation:
     - **Server 3 (Web Server)**: Runs Apache for HTTP requests and static content, free from other tasks.
     - **Server 4 (Application Server)**: Runs PHP-FPM and hosts the codebase for dynamic request processing.
     - **Server 5 (Database)**: Runs MySQL Primary and Replica, dedicated to database operations.

### Specifics About the Infrastructure
- **Load Balancer Cluster**: Server 1 (primary) and Server 2 (backup) form an Active-Passive cluster using Keepalived. The VIP routes traffic to Server 1 unless it fails, then switches to Server 2. HAProxy uses Round-Robin to forward requests to Server 3 (Apache), ready for additional web servers.
- **Component Separation Benefits**: Dedicated servers reduce resource contention, enable independent scaling (e.g., add more web servers), and isolate faults (e.g., MySQL failure on Server 5 doesn’t affect Server 3).
- **Apache Standardization**: Using Apache exclusively on Server 3 ensures consistent configuration and logging (e.g., `/var/log/apache2/access.log` for QPS).

## Issues with the Infrastructure
1. **SSL Termination at Load Balancer**: HAProxy (Server 1 or 2) decrypts HTTPS to HTTP, leaving internal traffic to Server 3 and Server 4 unencrypted, risking data exposure. **Mitigation**: Use SSL re-encryption or passthrough.
2. **Single MySQL Primary**: Server 5’s MySQL Primary handles all writes; a failure stops writes until the Replica is promoted. **Mitigation**: Automated failover (e.g., MySQL Orchestrator).
3. **Single Web and Application Server**: Server 3 (Apache) and Server 4 (PHP-FPM) are single instances, limiting scalability. **Mitigation**: Add more web and application servers.

## Conclusion
This five-server infrastructure scales up by adding Server 4 (application server) and Server 5 (database), a second HAProxy (Server 2) in an Active-Passive cluster with Server 1, and splitting components: Apache on Server 3, PHP-FPM on Server 4, MySQL on Server 5. Apache ensures web server consistency. The setup improves performance, scalability, and fault isolation while maintaining security (firewalls, HTTPS) and monitoring (Sumo Logic). Issues like SSL termination and single instances can be addressed with further redundancy.