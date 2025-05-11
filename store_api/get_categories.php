<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once("create_database.php");

$sql = "SELECT DISTINCT type FROM products";
$result = $conn->query($sql);

$categories = [];
while ($row = $result->fetch_assoc()) {
    $categories[] = $row['type'];
}

echo json_encode(["type" => $categories]);

$conn->close();
?>
