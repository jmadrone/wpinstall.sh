wpinstall.sh

# Bash Script to Install WordPress on Debian 12 or Ubuntu 24.04 systems

Bash script to install WordPress on a VPS running Debian  or Ubuntu Linux OS. The script will install a LAMP stack using system packages, including PHP, Apache, and MariaDB. The script will create a database, configure the database, and install and configure WordPress. The script utilizes the WordPress.org API to create secure and unique auth keys and salts which are updated in `wp-config.php`.

> 📝 NOTE  
> Script must be run as `root` user, or with `sudo`.

The script supports both **predefined variables** and **interactive input**.

If environment variables (`rootpass`, `dbname`, `dbuser`, `userpass`, `wpurl`) are set before running the script, it will use those values. Otherwise, it will prompt the user interactively.

The only dependency required is `git`, which should be pre-installed. If it is not installed, update the system packages and install it like this:

```sh
sudo apt-get update && sudo apt-get install git -y
```

## INSTRUCTIONS

1. Launch instance using Debian 12 or Ubuntu 24.04 on favorite cloud provider
2. Clone the repository with

   ```sh
   git clone https://github.com/jmadrone/wpinstall.sh
   ```

3. Make script executable with

   ```sh
   cd wpinstall.sh
   chmod +x wpinstall.sh
   ```

4. Execute `wpinstall.sh` install script

   ```sh
   sudo ./wpinstall.sh
   ```

### EXAMPLE USING PRE-DEFINED ENVIRONMENT VARIABLES

1. Define environment variables

   ```sh
   export rootpass="<insert your password here>"
   export userpass="<insert your password here>"
   export dbname="wordpressdb"
   export dbuser="wpuser"
   export wpurl="mywebsite.com"
   ```

2. Clone the repo, make executable, and run the script

   ```sh
   git clone https://github.com/jmadrone/wpinstall.sh
   cd wpinstall.sh && chmod +x wpinstall.sh
   sudo ./wpinstall.sh
   ```
