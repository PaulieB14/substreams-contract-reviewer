#!/bin/bash
# Setup script for the web server on Hetzner

# Install Apache and PHP
apt-get update
apt-get install -y apache2 php libapache2-mod-php

# Create data directory
mkdir -p /var/www/html/data

# Set up a cron job to copy data from the storage location to the web server
cat > /etc/cron.hourly/update-contract-data << 'CRON'
#!/bin/bash
# Copy the latest contract data to the web server
cp /path/to/substreams-data/*.json /var/www/html/data/
CRON
chmod +x /etc/cron.hourly/update-contract-data

# Enable the site
a2ensite 000-default
systemctl reload apache2

echo "Web dashboard setup complete!"
