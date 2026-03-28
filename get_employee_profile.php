<?php
// get_employee_profile.php
// HR can fetch an employee profile by id

include "config.php";

$hr_id = isset($_GET['hr_id']) ? intval($_GET['hr_id']) : (isset($_POST['hr_id']) ? intval($_POST['hr_id']) : 0);
$emp_id = isset($_GET['employee_id']) ? intval($_GET['employee_id']) : (isset($_POST['employee_id']) ? intval($_POST['employee_id']) : 0);

if ($hr_id == 0 || $emp_id == 0) {
    echo json_encode(["success" => false, "message" => "Provide hr_id and employee_id"]);
    exit;
}

// verify hr role
$stmt = mysqli_prepare($conn, "SELECT role FROM users WHERE id = ? LIMIT 1");
mysqli_stmt_bind_param($stmt, 'i', $hr_id);
mysqli_stmt_execute($stmt);
mysqli_stmt_bind_result($stmt, $hr_role);
if (!mysqli_stmt_fetch($stmt)) {
    mysqli_stmt_close($stmt);
    echo json_encode(["success" => false, "message" => "HR user not found"]);
    exit;
}
mysqli_stmt_close($stmt);

if (strtolower(trim($hr_role)) !== 'hr') {
    echo json_encode(["success" => false, "message" => "Unauthorized: only HR can access employee profiles"]);
    exit;
}

// fetch employee
$q = mysqli_prepare($conn, "SELECT id, role, full_name, email, phone, profile_image, resume_file, dob, created_at FROM users WHERE id = ? LIMIT 1");
mysqli_stmt_bind_param($q, 'i', $emp_id);
mysqli_stmt_execute($q);
mysqli_stmt_bind_result($q, $id, $role, $full_name, $email, $phone, $profile_image, $resume_file, $dob, $created_at);
if (!mysqli_stmt_fetch($q)) {
    mysqli_stmt_close($q);
    echo json_encode(["success" => false, "message" => "Employee not found"]);
    exit;
}
mysqli_stmt_close($q);

// Build profile response (include some computed fields HR UI might expect)
$profile = [
    'id' => intval($id),
    'role' => $role,
    'full_name' => $full_name,
    'email' => $email,
    'phone' => $phone,
    'profile_image' => $profile_image,
    'resume_file' => $resume_file,
    'dob' => $dob,
    'created_at' => $created_at,
    // UI-friendly extras
    'designation' => '',
    'emp_code' => sprintf('EMP-%04d', $id)
];

echo json_encode(["success" => true, "employee" => $profile]);

?>
