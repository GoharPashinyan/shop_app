<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

ob_start();

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

require_once("create_database.php");

$input = file_get_contents("php://input");
$data = json_decode($input, true);

file_put_contents("debug.log", print_r($data, true) . "\n", FILE_APPEND);

if (!$data) {
    response(false, "Invalid JSON data!");
}

if (empty($data['username']) || empty($data['email']) || empty($data['password'])) {
    response(false, "All fields are required!");
}

$username = trim($data['username']);
$email = trim($data['email']);
$password = trim($data['password']);

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    response(false, "Invalid email format!");
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

try {
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    if (!$stmt) {
        throw new Exception("Prepare statement failed: " . $conn->error);
    }
    
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        response(false, "Email already registered!");
    }

    $stmt->close();

    $stmt = $conn->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Prepare statement failed: " . $conn->error);
    }

    $stmt->bind_param("sss", $username, $email, $hashedPassword);
    if ($stmt->execute()) {
        response(true, "Registration successful!");
    } else {
        response(false, "Error: " . $stmt->error);
    }

    $stmt->close();
} catch (Exception $e) {
    response(false, "Error: " . $e->getMessage());
} finally {
    $conn->close();
}

function response($success, $message) {
    echo json_encode(["success" => $success, "message" => $message]);
    exit;
}

$response = array("success" => true, "message" => "Registration successful!");
echo json_encode($response);