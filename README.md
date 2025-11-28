# Site Deployer

  

  

Site Deployer is a comprehensive tool designed to automate the deployment of Frappe/ERPNext applications using Docker Swarm, Portainer, Traefik, and MariaDB. It simplifies the process of setting up a single-tenant Frappe bench with optional site restoration from backups.

  

  

## Features

  

  

-  **Automated Deployment**: Spin up a complete Frappe/ERPNext environment with a single command.

  

-  **Docker Swarm Integration**: Utilizes Docker Swarm for container orchestration.

  

-  **Portainer Management**: Deploys and manages stacks through the Portainer web interface.

  

-  **Traefik Reverse Proxy**: Handles routing, SSL certificates, and load balancing.

  

-  **MariaDB Database**: Configurable MariaDB setup for data persistence.

  

-  **Backup Restoration**: Optional restoration of existing sites from backup files.

  

-  **Environment Configuration**: Easy configuration through environment variables.

  

-  **Multi-Service Architecture**: Includes backend, frontend, workers, scheduler, Redis, and WebSocket services.

  

  

## Prerequisites

  

  

Before using Site Deployer, ensure you have the following installed and configured:

  

  

-  **Docker**: Version 20.10 or later

  

-  **Git**: For cloning the repository

  

-  **Linux**: The scripts are designed for Unix-like systems

-  **Windows** : Use "Git Bash Here" option for running Unix-like command

  

## Installation

1.  **Clone the Repository**:

```bash
git  clone  https://github.com/your-username/site-deployer.git
cd  site-deployer
``` 

2.  **Make Scripts Executable**: 

```bash
chmod  +x  *.sh
```

for giving permission to the file

**For Windows :**

a.Go to file manager right click on the site-depolyer folder

b.Click on the more options->click on the **Git bash here** 

c.Inside that Run the `bash main.sh` in the git bash terminal

3.  **Install Dependencies** (if not already installed):

- Docker: Follow the [official Docker installation guide](https://docs.docker.com/get-docker/)

  
  

## Configuration

1.  **Edit `variable.env`**:

Update the following variables in the `variable.env` file:


```env 
IMAGE=lenscx # Docker image name
VERSION=v15.48.0 # Version tag
BENCH_NAME=my-bench # Name of the Frappe bench
SITES=example.com # Domain(s) for the site
MARIADB_NETWORK=mariadb # MariaDB network name
DATABASE_HOST=mariadb # MariaDB host
DB_PASSWORD=your_db_password # Database password
ADMIN_PASSWORD=your_admin_password # Frappe admin password
SITE_NAME=example.com # Site name
PORTAINER_API_KEY=your_portainer_api_key # Portainer API key
```  

Example :

```env
IMAGE=lenscx
VERSION=v15.48.0
BENCH_NAME=test-amr-pub
SITES=qsgbin.docker.localhost
MARIADB_NETWORK=test-amr-pub-db
DATABASE_HOST=test-amr-pub-db
DB_PASSWORD=admin@123
ADMIN_PASSWORD=admin@123
SITE_NAME=test.docker.localhost
PORTAINER_API_KEY=your_portainer_api_key

```

2.  **Prepare Backup Files** (optional):

If you want to restore a site, place your backup files in the `backups/` directory:

-  `*.sql.gz`: Database backup

-  `*com-files*.tar`: Public files

-  `*com-private-files*.tar`: Private files

-  `*.json`: Site configuration (optional, for encrypted backups)

## Usage

### Full Deployment (Setup + Deploy + Restore)

Run the main script to perform a complete deployment:

  
```bash
./main.sh
``` 

This script will:

1. Check for Portainer setup

2. Run setup if Portainer doesn't exist

3. Deploy the site stacks

4. Optionally restore from backup
  

### Manual Steps

#### 1. Initial Setup 

If Portainer is not set up, run:

```bash
./setup.sh
```

This initializes Docker Swarm, sets up Traefik and Portainer.

**Important**:

->After running `setup.sh`, go to `https://portainer.docker.localhost` and complete the admin user setup before proceeding to the next step.

#### 2. Deploy Site

After setting up Portainer and obtaining the API key:

```bash
./deploy.sh
```

This deploys MariaDB, ERPNext bench, configuration, and site creation stacks to Portainer.

**Important**:

->User need to check the site stack service is in complete state
  

**If the above checklist is checked the user can proceed with step 3 (restore )**


#### 3. Restore Backup (Optional)

If you have backup files:

```bash
./restore_backup.sh
```

This copies backup files to the container and performs restoration.

## Docker Compose Files

The `compose/` directory contains the following YAML files:

-  `traefik-host.yml`: Traefik reverse proxy configuration

-  `portainer.yml`: Portainer management interface

-  `mariadb.yml`: MariaDB database service

-  `erpnext.yml`: Main ERPNext/Frappe services (backend, frontend, workers, etc.)

-  `configure-erpnext.yml`: Bench configuration

-  `create-site.yml`: Site creation


## Troubleshooting

### Common Issues

1.  **Portainer Access**:

- Ensure Portainer is accessible at `https://portainer.docker.localhost`

- Check that the API key is correctly set in variable.env

```env
IMAGE=lenscx
VERSION=v15.48.0
BENCH_NAME=qsgbin-amr-pub
SITES=`qsgbin.docker.localhost`
MARIADB_NETWORK=qsgbin-amr-pub-db
DATABASE_HOST=qsgbin-amr-pub-db
DB_PASSWORD=admin@123
ADMIN_PASSWORD=admin@123
SITE_NAME=qsgbin.docker.localhost
PORTAINER_API_KEY=your_portainer_api_key # Portainer API key
```


for portainer API token Go to **Account ->Access token ->Generate token** and create token and paste in the`variable.env`file


2.  **SSL Certificates**:

- Traefik handles Let's Encrypt certificates automatically for production domains

- For local development, certificates may need manual configuration

3.  **Database Connection**:

- Verify MariaDB network and credentials in `variable.env`

- Check Docker network connectivity

4.  **Backup Restoration**:

- Ensure backup files are in the correct format and location

- Check file permissions and container access
- 
### Logs

Check logs for individual services:

```bash
docker  service  logs <service_name>
```

Or view Portainer logs through the web interface. 

**Note**: This tool is designed for development and production deployments of Frappe/ERPNext. Always test in a development environment before deploying to production.
