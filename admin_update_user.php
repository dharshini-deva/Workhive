<?php
include "config.php";
header("Content-Type: application/json");
http_response_code(200);

// Disable display errors to prevent breaking JSON, but log them
ini_set('display_errors', 0);
error_reporting(E_ALL);

// Safe parameter retrieval
function get_param($key) {
    return isset($_POST[$key]) ? trim($_POST[$key]) : '';
}

$user_id   = get_param('user_id');
$full_name = get_param('full_name');
$email     = get_param('email');
$phone     = get_param('phone');
$role      = get_param('role');

if (empty($user_id)) {
    echo json_encode(["success" => false, "message" => "User ID is required"]);
    exit;
}

if (!$conn) {
    echo json_encode(["success" => false, "message" => "Database connection error"]);
    exit;
}

// Determine if we use prepared statements or fallback
// Try Prepared Statement
$sql = "UPDATE users SET full_name=?, email=?, phone=?, role=? WHERE id=?";
$stmt = mysqli_prepare($conn, $sql);

if ($stmt) {
    mysqli_stmt_bind_param($stmt, "sssss", $full_name, $email, $phone, $role, $user_id);
    
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Update error: " . mysqli_stmt_error($stmt)]);
    }
    mysqli_stmt_close($stmt);
} else {
    // Fallback or Error reporting
    echo json_encode(["success" => false, "message" => "Query prepare failed: " . mysqli_error($conn)]);
}
?>
