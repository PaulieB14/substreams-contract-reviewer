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
