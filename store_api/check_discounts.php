<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');
include 'create_database.php';

$user_id = $_GET['user_id'];

$sql = "SELECT p.name, p.Discount 
        FROM cart_items c
        JOIN Products p ON c.product_id = p.id
        WHERE c.user_id = ? AND p.Discount > 0";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$discounted_products = [];

while ($row = $result->fetch_assoc()) {
    $discounted_products[] = $row;
}

echo json_encode(["products" => $discounted_products]);

$stmt->close();
$conn->close();
?>
