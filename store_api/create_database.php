<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "storeDB";

$conn = new mysqli($servername, $username, $password);

if ($conn->connect_error) {
    die("Կապի սխալ: " . $conn->connect_error);
}

$sql = "CREATE DATABASE IF NOT EXISTS $dbname";
if (!$conn->query($sql)) {
    die("Տվյալների բազայի ստեղծման սխալ: " . $conn->error);
}

$conn->select_db($dbname);

$product_sql = "CREATE TABLE IF NOT EXISTS products (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Type VARCHAR(255), 
    Name VARCHAR(255),
    Price DECIMAL(10,2),
    image VARCHAR(255),
    Discount VARCHAR(255)
)";

if (!$conn->query($product_sql)) {
    echo "Աղյուսակի ստեղծման սխալ (products): " . $conn->error;
}

$users_sql = "CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if (!$conn->query($users_sql)) {
    echo "Աղյուսակի ստեղծման սխալ (users): " . $conn->error;
}

$cart_sql = "CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    Discount VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id) 
  )";
  
  if (!$conn->query($cart_sql)) {
    echo "cart i ստեղծման սխալ (cart): " . $conn->error;
}
?>
