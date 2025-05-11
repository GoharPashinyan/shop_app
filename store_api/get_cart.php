<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
include 'create_database.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $user_id = $_GET['user_id'];
    error_log("Fetching cart for user_id: $user_id");

    $query = "SELECT c.id, c.product_id, c.discount, p.Name, p.Price, p.image FROM cart_items c 
              JOIN products p ON c.product_id = p.ID WHERE c.user_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $cartItems = [];
    while ($row = $result->fetch_assoc()) {
        $cartItems[] = $row;
    }

    if (empty($cartItems)) {
        error_log("No items found for user_id: $user_id");
    } else {
        error_log("Found cart items: " . json_encode($cartItems));
    }

    echo json_encode(["success" => true, "cart_items" => $cartItems]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>
