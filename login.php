<?php
include "config.php";

$email = $_POST['email'] ?? "";
$password = $_POST['password'] ?? "";
$role = $_POST['role'] ?? "";

if ($email == "" || $password == "" || $role == "") {
    echo json_encode([
        "success" => false,
        "message" => "Missing parameters"
    ]);
    exit;
}
$query = "SELECT * FROM users 
          WHERE email='$email' 
          AND password='$password'
          AND role='$role' 
          AND is_active=1";
$result = mysqli_query($conn, $query);
if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);

    echo json_encode([
        "success" => true,
        "message" => "Login successful",
        "data" => [
            "id" => $user['id'],
            "role" => $user['role'],
            "full_name" => $user['full_name'],
            "email" => $user['email']
        ]
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid credentials"
    ]);
}
?>
