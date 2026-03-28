<?php
include "config.php";

$admin_id  = intval($_POST['admin_id'] ?? 0);
$full_name = $_POST['full_name'] ?? '';
$dob       = $_POST['dob'] ?? '';
$phone     = $_POST['phone'] ?? '';
$email     = $_POST['email'] ?? '';

// ✅ Verify Admin
$check = mysqli_query(
    $conn,
    "SELECT id FROM users WHERE id=$admin_id AND role='Admin'"
);

if (mysqli_num_rows($check) == 0) {
    echo json_encode(["success" => false, "message" => "Unauthorized"]);
    exit;
}

// ✅ Handle image upload (OPTIONAL)
$profileImagePath = "";

if (!empty($_FILES['profile_image']['name'])) {

    // Create folder if not exists
    if (!is_dir("uploads/admin")) {
        mkdir("uploads/admin", 0777, true);
    }

    $imageName = time() . "_" . $_FILES['profile_image']['name'];
    $target = "uploads/admin/" . $imageName;

    move_uploaded_file($_FILES['profile_image']['tmp_name'], $target);
    $profileImagePath = $target;
}

// ✅ Update query
$sql = "UPDATE admin_profile SET
            full_name = '$full_name',
            dob = '$dob',
            phone = '$phone',
            email = '$email'";

if ($profileImagePath != "") {
    $sql .= ", profile_image = '$profileImagePath'";
}

$sql .= " WHERE admin_id = $admin_id";

mysqli_query($conn, $sql);

echo json_encode([
    "success" => true,
    "message" => "Admin profile updated"
]);
?>
