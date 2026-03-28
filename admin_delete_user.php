<?php
include "config.php";
header("Content-Type: application/json");

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['user_id'])) {
    echo json_encode([
        "success" => false,
        "message" => "User ID required"
    ]);
    exit;
}

$userId = mysqli_real_escape_string($conn, $data['user_id']);

// 🔐 Check role of target user
$checkSql = "SELECT role FROM users WHERE id = '$userId' LIMIT 1";
$result = mysqli_query($conn, $checkSql);

if (!$result || mysqli_num_rows($result) === 0) {
    echo json_encode([
        "success" => false,
        "message" => "User not found"
    ]);
    exit;
}

$row = mysqli_fetch_assoc($result);

if ($row['role'] === 'admin') {
    echo json_encode([
        "success" => false,
        "message" => "Admin account cannot be deleted"
    ]);
    exit;
}

// 🗑 Delete user
$deleteSql = "DELETE FROM users WHERE id = '$userId'";
$deleted = mysqli_query($conn, $deleteSql);

if ($deleted) {
    echo json_encode([
        "success" => true,
        "message" => "User deleted successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to delete user"
    ]);
}
