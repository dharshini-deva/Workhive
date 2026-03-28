<?php
header("Content-Type: application/json");
include "config.php";

/* Allow only POST */
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "success" => false,
        "message" => "POST method required"
    ]);
    exit;
}

/* Get POST values */
$user_id    = intval($_POST['user_id'] ?? 0);
$leave_type = trim($_POST['leave_type'] ?? "");
$start_date = trim($_POST['start_date'] ?? "");
$end_date   = trim($_POST['end_date'] ?? "");
$duration   = trim($_POST['duration'] ?? "");
$reason     = trim($_POST['reason'] ?? "");

/* Validation */
if (
    $user_id == 0 ||
    $leave_type == "" ||
    $start_date == "" ||
    $end_date == ""
) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields"
    ]);
    exit;
}

/* 🔐 CHECK USER ROLE (VERY IMPORTANT) */
$roleCheck = mysqli_query(
    $conn,
    "SELECT role FROM users WHERE id = $user_id"
);

if (mysqli_num_rows($roleCheck) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid user"
    ]);
    exit;
}

$user = mysqli_fetch_assoc($roleCheck);

/* ❌ Allow ONLY Employee */
if ($user['role'] !== 'Employee') {
    echo json_encode([
        "success" => false,
        "message" => "Only employees can apply for leave"
    ]);
    exit;
}

/* Force status */
$status = "PENDING";

/* Insert leave request */
$sql = "INSERT INTO leave_requests 
        (user_id, leave_type, start_date, end_date, duration, reason, status)
        VALUES 
        ($user_id, '$leave_type', '$start_date', '$end_date', '$duration', '$reason', '$status')";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Leave request submitted successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to submit leave request"
    ]);
}
?>
