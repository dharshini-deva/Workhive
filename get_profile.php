<?php
include "config.php";

$user_id = $_POST['user_id'] ?? 0;

/* Validate required fields */
if ($user_id == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Missing user_id"
    ]);
    exit;
}

/* Fetch user profile data */
$user_id = intval($user_id);
$query = "SELECT 
    id,
    role,
    full_name,
    email,
    phone,
    profile_image,
    dob
FROM users 
WHERE id=$user_id 
AND is_active=1";

$result = mysqli_query($conn, $query);

if (!$result) {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . mysqli_error($conn)
    ]);
    exit;
}

if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);
    
    echo json_encode([
        "success" => true,
        "message" => "Profile fetched successfully",
        "data" => [
            "id" => $user['id'],
            "role" => $user['role'],
            "full_name" => $user['full_name'],
            "email" => $user['email'],
            "phone" => $user['phone'],
            "profile_image" => $user['profile_image'],
            "dob" => $user['dob'] ?? "—"
        ]
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "User not found"
    ]);
}
mysqli_close($conn);
?>
