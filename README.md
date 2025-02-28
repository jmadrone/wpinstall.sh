wpinstall.sh

# Bash Script to Install WordPress on Debian 12 or Ubuntu 24.04 systems

Bash script to install WordPress on a VPS running Debian  or Ubuntu Linux OS.

> ‼️ IMPORTANT  
> Script assumes you have a basic LAMP stack pre-installed: Apache2, PHP, MySQL or MariaDB.

> 📝 NOTE  
> Script must be run as root user, or with 'sudo'.

## INSTRUCTIONS

1. Launch instance using Debian 12 or Ubuntu 24.04 on favorite cloud provider
2. Download script from [GitHub Gist]() with

        wget 
3. Make script executable with

        chmod +x wpinstall.sh
4. Execute `wpinstall.sh` install script

        sudo ./wpinstall.sh

The script supports both **predefined variables** and **interactive input**. If environment variables (rootpass, dbname, dbuser, userpass, wpURL) are set before running the script, it will use those values. Otherwise, it will prompt the user interactively.
