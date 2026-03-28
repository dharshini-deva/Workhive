<?php
// process_manager_request.php
// Director approves or rejects a manager request and manager is notified

include "config.php";

$director_id = intval($_POST['director_id'] ?? 0);
$request_id  = intval($_POST['request_id'] ?? 0);
$action      = trim($_POST['action'] ?? ''); // 'approve' or 'reject'
$comment     = trim($_POST['comment'] ?? '');

if ($director_id == 0 || $request_id == 0 || !in_array($action, ['approve','reject'])) {
    echo json_encode(["success" => false, "message" => "Missing/invalid fields"]);
    exit;
}

// Verify the actor is actually a Director
$roleRes = mysqli_query($conn, "SELECT role FROM users WHERE id = $director_id LIMIT 1");
if (!$roleRes || mysqli_num_rows($roleRes) == 0) {
    echo json_encode(["success" => false, "message" => "Director user not found"]);
    exit;
}
$roleRow = mysqli_fetch_assoc($roleRes);
$roleStr = strtolower(trim($roleRow['role'] ?? ''));
if ($roleStr !== 'director') {
    echo json_encode(["success" => false, "message" => "Unauthorized: only Director can approve or reject requests"]);
    exit;
}

// verify request exists
$res = mysqli_query($conn, "SELECT id, manager_id, title, request_type FROM manager_requests WHERE id = $request_id LIMIT 1");
if (!$res || mysqli_num_rows($res) == 0) {
    echo json_encode(["success" => false, "message" => "Request not found"]);
    exit;
}
$req = mysqli_fetch_assoc($res);
$manager_id = intval($req['manager_id']);
$title = $req['title'];
$request_type = $req['request_type'];

$newStatus = $action === 'approve' ? 'approved' : 'rejected';

// update request status
$stmt = mysqli_prepare($conn, "UPDATE manager_requests SET status = ?, updated_at = NOW() WHERE id = ?");
mysqli_stmt_bind_param($stmt, 'si', $newStatus, $request_id);
mysqli_stmt_execute($stmt);
mysqli_stmt_close($stmt);

// create notification for manager
$notifTitle = $action === 'approve' ? 'Request Approved' : 'Request Rejected';
$notifMessage = "Your request ('" . $title . "') was " . $newStatus . ".";
if ($comment) $notifMessage .= " Comment: " . $comment;
$data = json_encode(["request_id" => $request_id, "action" => $newStatus, "by" => $director_id]);

$stmt2 = mysqli_prepare($conn, "INSERT INTO notifications (user_id, sender_id, title, message, data, is_read) VALUES (?, ?, ?, ?, ?, 0)");
mysqli_stmt_bind_param($stmt2, 'iisss', $manager_id, $director_id, $notifTitle, $notifMessage, $data);
mysqli_stmt_execute($stmt2);
mysqli_stmt_close($stmt2);

echo json_encode(["success" => true, "message" => "Request $newStatus", "request_id" => $request_id]);

?>
