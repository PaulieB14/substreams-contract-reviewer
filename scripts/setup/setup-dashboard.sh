#!/bin/bash
# Script to set up a simple web dashboard on Hetzner server

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}

echo "=== Setting up web dashboard on Hetzner server ==="
echo "Server IP: $HETZNER_IP"
echo ""

# Create dashboard files locally
mkdir -p dashboard
cat > dashboard/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contract Reviewer Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { padding: 20px; }
        .card { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="my-4">Contract Reviewer Dashboard</h1>
        
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Contract Activity Overview</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="activityChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Top Contracts by Unique Wallets</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="walletsChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h5>Recent Contracts</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Contract Address</th>
                                <th>First Interaction</th>
                                <th>Last Interaction</th>
                                <th>Total Calls</th>
                                <th>Unique Wallets</th>
                            </tr>
                        </thead>
                        <tbody id="contractsTable">
                            <tr>
                                <td colspan="5" class="text-center">Loading data...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Sample data - this would be replaced with actual data from your API
        const sampleData = [
            { address: "0x1234567890abcdef1234567890abcdef12345678", first_interaction_block: 16000000, last_interaction_block: 16001000, total_calls: 150, unique_wallets: 45 },
            { address: "0xabcdef1234567890abcdef1234567890abcdef12", first_interaction_block: 16000100, last_interaction_block: 16000900, total_calls: 120, unique_wallets: 35 },
            { address: "0x7890abcdef1234567890abcdef1234567890abcd", first_interaction_block: 16000200, last_interaction_block: 16000800, total_calls: 100, unique_wallets: 30 },
            { address: "0x567890abcdef1234567890abcdef1234567890ab", first_interaction_block: 16000300, last_interaction_block: 16000700, total_calls: 80, unique_wallets: 25 },
            { address: "0x34567890abcdef1234567890abcdef1234567890", first_interaction_block: 16000400, last_interaction_block: 16000600, total_calls: 60, unique_wallets: 20 }
        ];

        // Populate table
        function populateTable(data) {
            const tableBody = document.getElementById('contractsTable');
            tableBody.innerHTML = '';
            
            data.forEach(contract => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><a href="https://etherscan.io/address/${contract.address}" target="_blank">${contract.address.substring(0, 10)}...</a></td>
                    <td>${contract.first_interaction_block}</td>
                    <td>${contract.last_interaction_block}</td>
                    <td>${contract.total_calls}</td>
                    <td>${contract.unique_wallets}</td>
                `;
                tableBody.appendChild(row);
            });
        }

        // Create charts
        function createCharts(data) {
            // Activity Chart
            const activityCtx = document.getElementById('activityChart').getContext('2d');
            new Chart(activityCtx, {
                type: 'bar',
                data: {
                    labels: data.map(c => c.address.substring(0, 10) + '...'),
                    datasets: [{
                        label: 'Total Calls',
                        data: data.map(c => c.total_calls),
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });

            // Wallets Chart
            const walletsCtx = document.getElementById('walletsChart').getContext('2d');
            new Chart(walletsCtx, {
                type: 'pie',
                data: {
                    labels: data.map(c => c.address.substring(0, 10) + '...'),
                    datasets: [{
                        label: 'Unique Wallets',
                        data: data.map(c => c.unique_wallets),
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.5)',
                            'rgba(54, 162, 235, 0.5)',
                            'rgba(255, 206, 86, 0.5)',
                            'rgba(75, 192, 192, 0.5)',
                            'rgba(153, 102, 255, 0.5)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)'
                        ],
                        borderWidth: 1
                    }]
                }
            });
        }

        // Initialize with sample data
        document.addEventListener('DOMContentLoaded', () => {
            populateTable(sampleData);
            createCharts(sampleData);
            
            // In a real implementation, you would fetch data from your API
            // fetch('/api/contracts')
            //     .then(response => response.json())
            //     .then(data => {
            //         populateTable(data);
            //         createCharts(data);
            //     });
        });
    </script>
</body>
</html>
EOF

cat > dashboard/api.php << 'EOF'
<?php
header('Content-Type: application/json');

// Path to the JSON data files
$dataDir = '/var/www/html/data';

// Get all JSON files in the data directory
$files = glob($dataDir . '/*.json');

// Read and combine data from all files
$allContracts = [];
foreach ($files as $file) {
    $content = file_get_contents($file);
    $contracts = json_decode($content, true);
    if (is_array($contracts)) {
        $allContracts = array_merge($allContracts, $contracts);
    }
}

// Sort by total_calls in descending order
usort($allContracts, function($a, $b) {
    return $b['total_calls'] - $a['total_calls'];
});

// Return the top 100 contracts
echo json_encode(array_slice($allContracts, 0, 100));
EOF

cat > dashboard/setup-server.sh << 'EOF'
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
EOF

chmod +x dashboard/setup-server.sh

# Copy dashboard files to Hetzner server (force IPv4)
echo "Copying dashboard files to Hetzner server (IPv4 only)..."
scp -4 -r dashboard ${HETZNER_USER}@${HETZNER_IP}:/tmp/

# Set up the web server on Hetzner (force IPv4)
echo "Setting up web server on Hetzner (IPv4 only)..."
ssh -4 ${HETZNER_USER}@${HETZNER_IP} "cd /tmp/dashboard && ./setup-server.sh && cp -r * /var/www/html/ && rm -rf /tmp/dashboard"

echo ""
echo "=== Dashboard setup complete ==="
echo ""
echo "You can access your dashboard at:"
echo "http://${HETZNER_IP}/"
echo ""
echo "Note: You may need to adjust the data path in api.php to match your actual storage location."
