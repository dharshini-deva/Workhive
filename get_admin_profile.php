<?php
include "config.php";

$admin_id = intval($_POST['admin_id'] ?? 0);

$q = mysqli_query(
    $conn,
    "SELECT full_name, dob, phone, email, profile_image
     FROM admin_profile
     WHERE admin_id = $admin_id"
);

if (mysqli_num_rows($q) == 1) {
    echo json_encode([
        "success" => true,
        "data" => mysqli_fetch_assoc($q)
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Profile not found"
    ]);
}
?>
