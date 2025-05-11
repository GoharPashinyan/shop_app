<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'create_database.php';

header("Content-Type: application/json");

if (!isset($_GET['type']) || empty($_GET['type'])) {
    echo json_encode(['success' => false, 'message' => 'Type parameter is missing']);
    exit();
}

$type = $_GET['type'];

if (!$conn) {
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit();
}

$query = "SELECT * FROM products WHERE type = ?";
$stmt = mysqli_prepare($conn, $query);
mysqli_stmt_bind_param($stmt, "s", $type);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) > 0) {
    $products = [];
    while ($row = mysqli_fetch_assoc($result)) {
        if (!empty($row['image'])) {
            $images = json_decode($row['image'], true);

            if (json_last_error() === JSON_ERROR_NONE) {
                $row['image'] = $images;
            } else {
                $row['image'] = [$row['image']];
            }
        } else {
            $row['image'] = [];
        }

        $products[] = $row;
    }
    echo json_encode(['success' => true, 'products' => $products]);
} else {
    echo json_encode(['success' => false, 'message' => 'No products found']);
}

mysqli_stmt_close($stmt);
mysqli_close($conn);
?>
