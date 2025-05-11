<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
include 'create_database.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $product_id = $_POST['product_id'];
    $discount = $_POST['discount'];

    $checkQuery = "SELECT * FROM cart_items WHERE user_id = ? AND product_id = ?";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("ii", $user_id, $product_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows == 0) {
        $insertQuery = "INSERT INTO cart_items (user_id, product_id, discount) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($insertQuery);
        $stmt->bind_param("iid", $user_id, $product_id, $discount);
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Product added to cart"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to add product"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Product already in cart"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>
