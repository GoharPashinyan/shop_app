<?php
include('create_database.php');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$csvFile = __DIR__ . '/Filtered.csv';

if (!file_exists($csvFile)) {
    die(json_encode(["error" => "❌ CSV ֆայլը չի գտնվել։"]));
}

$tableCheck = $conn->query("SHOW TABLES LIKE 'products'");
if ($tableCheck->num_rows == 0) {
    die(json_encode(["error" => "❌ 'products' աղյուսակը գոյություն չունի։"]));
}

$conn->query("TRUNCATE TABLE products");

if (($handle = fopen($csvFile, 'r')) !== FALSE) {
    $firstLine = true;
    $importedCount = 0;

    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        if ($firstLine) {
            $firstLine = false;
            continue;
        }

        $type = $conn->real_escape_string($data[0]);
        $name = $conn->real_escape_string($data[1]);
        $price = floatval($data[2]);
        $image = $conn->real_escape_string($data[3]);
        $discount = $conn->real_escape_string($data[4]);

        $sql = "INSERT INTO products (type, name, price, image, discount) 
                VALUES ('$type', '$name', '$price', '$image', '$discount')";

        if ($conn->query($sql)) {
            $importedCount++;
        } else {
            error_log("❌ Սխալ ներմուծման ժամանակ: " . $conn->error);
        }
    }
    fclose($handle);
    
    echo json_encode(["success" => "✅ $importedCount տվյալ հաջողությամբ ներմուծվել են։"]);
} else {
    echo json_encode(["error" => "❌ CSV ֆայլը չի կարող բացվել։"]);
}
$mysqli->query("SET FOREIGN_KEY_CHECKS = 0;");

$conn->close();
?>
