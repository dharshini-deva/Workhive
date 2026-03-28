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

/* Read JSON body if sent */
$input = json_decode(file_get_contents("php://input"), true);

/* Get parameters (support form-data + JSON) */
$leave_id = intval($_POST['leave_id'] ?? $input['leave_id'] ?? 0);
$action   = strtolower($_POST['action'] ?? $input['action'] ?? '');
$hr_id    = intval($_POST['hr_id'] ?? $input['hr_id'] ?? 0);

/* Validation */
if ($leave_id == 0 || !in_array($action, ['accept', 'reject', 'delete']) || $hr_id == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Missing or invalid parameters. Provide action 'accept', 'reject' or 'delete'."
    ]);
    exit;
}

/* 🔐 Verify HR role */
$roleCheck = mysqli_query(
    $conn,
    "SELECT role FROM users WHERE id = $hr_id"
);

if (mysqli_num_rows($roleCheck) == 0) {
    echo json_encode(["success" => false, "message" => "Invalid HR user"]);
    exit;
}

$user = mysqli_fetch_assoc($roleCheck);

if ($user['role'] !== 'HR') {
    echo json_encode(["success" => false, "message" => "Unauthorized"]);
    exit;
}

/* Fetch leave request */
$leaveQuery = mysqli_query(
    $conn,
    "SELECT user_id FROM leave_requests WHERE id = $leave_id"
);

if (mysqli_num_rows($leaveQuery) == 0) {
    echo json_encode(["success" => false, "message" => "Leave request not found"]);
    exit;
}

$leave = mysqli_fetch_assoc($leaveQuery);
$employee_id = $leave['user_id'];

/* Process action */
if ($action === 'accept') {
    $status = 'APPROVED';
} elseif ($action === 'reject') {
    $status = 'REJECTED';
} else { // delete
    mysqli_query($conn, "DELETE FROM leave_requests WHERE id = $leave_id");

    mysqli_query(
        $conn,
        "INSERT INTO notifications (user_id, sender_id, title, message)
         VALUES ($employee_id, $hr_id, 'Leave Deleted', 'Your leave request was deleted by HR')"
    );

    echo json_encode([
        "success" => true,
        "message" => "Leave deleted successfully"
    ]);
    exit;
}

/* Update leave status */
mysqli_query(
    $conn,
    "UPDATE leave_requests SET status='$status' WHERE id=$leave_id"
);

/* Notify employee */
mysqli_query(
    $conn,
    "INSERT INTO notifications (user_id, sender_id, title, message)
     VALUES ($employee_id, $hr_id, 'Leave $status', 'Your leave request has been $status')"
);

echo json_encode([
    "success" => true,
    "message" => "Leave $status successfully"
]);
?>
