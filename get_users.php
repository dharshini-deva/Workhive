<?php
header("Content-Type: application/json");
include "config.php";

$role = $_POST['role'] ?? '';

if ($role === '') {
    echo json_encode([
        "success" => false,
        "message" => "Role is required"
    ]);
    exit;
}

$stmt = $conn->prepare(
    "SELECT 
        id,
        full_name,
        email,
        profile_image
     FROM users
     WHERE role = ? AND is_active = 1"
);

$stmt->bind_param("s", $role);
$stmt->execute();

$result = $stmt->get_result();
$users = [];

while ($row = $result->fetch_assoc()) {

    // Optional: ensure image path is not null
    $row['profile_image'] = $row['profile_image'] ?? '';

    $users[] = [
    "id" => (int)$row['id'],                  // ✅ FIX
    "full_name" => $row['full_name'],
    "email" => $row['email'],
    "profile_image" => $row['profile_image'] ?: null
];

}

echo json_encode([
    "success" => true,
    "message" => "Users fetched successfully",
    "data" => $users
]);

$stmt->close();
$conn->close();
