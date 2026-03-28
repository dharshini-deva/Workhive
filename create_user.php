<?php
header("Content-Type: application/json");
include "config.php";

/* ============================
   RECEIVE FORM DATA
============================ */
$admin_id  = intval($_POST['admin_id'] ?? 0);
$role      = trim($_POST['role'] ?? "");
$full_name = trim($_POST['full_name'] ?? "");
$email     = trim($_POST['email'] ?? "");
$password  = trim($_POST['password'] ?? "");
$phone     = trim($_POST['phone'] ?? "");
$dob       = trim($_POST['dob'] ?? "");

/* ============================
   VALIDATION
============================ */
$missing = [];

if ($admin_id == 0) $missing[] = "admin_id";
if ($role === "") $missing[] = "role";
if ($full_name === "") $missing[] = "full_name";
if ($email === "") $missing[] = "email";
if ($password === "") $missing[] = "password";
if ($phone === "") $missing[] = "phone";
if ($dob === "") $missing[] = "dob";

if (!isset($_FILES['profile_image']) || $_FILES['profile_image']['error'] !== 0) {
    $missing[] = "profile_image";
}

if (!isset($_FILES['resume']) || $_FILES['resume']['error'] !== 0) {
    $missing[] = "resume";
}

if (!empty($missing)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields",
        "missing" => $missing
    ]);
    exit;
}

/* ============================
   VERIFY ADMIN
============================ */
$adminCheck = mysqli_query(
    $conn,
    "SELECT id FROM users WHERE id = $admin_id AND role = 'Admin'"
);

if (mysqli_num_rows($adminCheck) === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Unauthorized admin"
    ]);
    exit;
}

/* ============================
   UPLOAD PROFILE IMAGE
============================ */
$profileDir = __DIR__ . "/uploads/profiles/";
if (!is_dir($profileDir)) {
    mkdir($profileDir, 0777, true);
}

$profileExt = strtolower(pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION));
$profileName = strtolower($role) . "_profile_" . time() . "." . $profileExt;
$profileFullPath = $profileDir . $profileName;

if (!move_uploaded_file($_FILES['profile_image']['tmp_name'], $profileFullPath)) {
    echo json_encode([
        "success" => false,
        "message" => "Profile image upload failed"
    ]);
    exit;
}

$profileImagePath = "uploads/profiles/" . $profileName;

/* ============================
   UPLOAD RESUME
============================ */
$resumeDir = __DIR__ . "/uploads/resumes/";
if (!is_dir($resumeDir)) {
    mkdir($resumeDir, 0777, true);
}

$resumeExt = strtolower(pathinfo($_FILES['resume']['name'], PATHINFO_EXTENSION));
$resumeName = strtolower($role) . "_resume_" . time() . "." . $resumeExt;
$resumeFullPath = $resumeDir . $resumeName;

if (!move_uploaded_file($_FILES['resume']['tmp_name'], $resumeFullPath)) {
    echo json_encode([
        "success" => false,
        "message" => "Resume upload failed"
    ]);
    exit;
}

$resumePath = "uploads/resumes/" . $resumeName;

/* ============================
   INSERT USER (NO HASH)
============================ */
$query = "
INSERT INTO users (
    role,
    full_name,
    email,
    password,
    phone,
    dob,
    profile_image,
    resume_file,
    created_by
) VALUES (
    '$role',
    '$full_name',
    '$email',
    '$password',
    '$phone',
    '$dob',
    '$profileImagePath',
    '$resumePath',
    $admin_id
)
";

if (mysqli_query($conn, $query)) {
    echo json_encode([
        "success" => true,
        "message" => "$role account created successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Database insert failed",
        "error" => mysqli_error($conn)
    ]);
}
?>
