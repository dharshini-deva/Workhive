<?php
// create_manager_request.php
// Manager creates a request (budget / time / resource) visible to Director(s)

include "config.php";

$manager_id   = intval($_POST['manager_id'] ?? 0);
$project_id   = intval($_POST['project_id'] ?? 0);
$title        = trim($_POST['title'] ?? '');
$request_type = trim($_POST['request_type'] ?? '');
$details      = trim($_POST['details'] ?? '');
$value        = trim($_POST['value'] ?? '');

if ($manager_id == 0 || $title == '' || $request_type == '') {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

// Verify the actor is actually a Manager
$mgrRes = mysqli_query($conn, "SELECT role FROM users WHERE id = $manager_id LIMIT 1");
if (!$mgrRes || mysqli_num_rows($mgrRes) == 0) {
    echo json_encode(["success" => false, "message" => "Manager user not found"]);
    exit;
}
$mgrRow = mysqli_fetch_assoc($mgrRes);
$mgrRole = strtolower(trim($mgrRow['role'] ?? ''));
if ($mgrRole !== 'manager') {
    echo json_encode(["success" => false, "message" => "Unauthorized: only users with role 'Manager' can create requests"]);
    exit;
}

// ensure table exists
$createTbl = "CREATE TABLE IF NOT EXISTS manager_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manager_id INT NOT NULL,
    project_id INT DEFAULT 0,
    title VARCHAR(255) NOT NULL,
    request_type VARCHAR(64) NOT NULL,
    details TEXT,
    value VARCHAR(255),
    status VARCHAR(32) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
mysqli_query($conn, $createTbl);

// insert request
$stmt = mysqli_prepare($conn, "INSERT INTO manager_requests (manager_id, project_id, title, request_type, details, value) VALUES (?, ?, ?, ?, ?, ?)");
mysqli_stmt_bind_param($stmt, 'iissss', $manager_id, $project_id, $title, $request_type, $details, $value);
if (!mysqli_stmt_execute($stmt)) {
    echo json_encode(["success" => false, "message" => "Failed to create request", "error" => mysqli_error($conn)]);
    exit;
}
$request_id = mysqli_stmt_insert_id($stmt);
mysqli_stmt_close($stmt);

// notify all Directors
$res = mysqli_query($conn, "SELECT id FROM users WHERE role='Director'");
$directors = [];
while ($row = mysqli_fetch_assoc($res)) $directors[] = intval($row['id']);

foreach ($directors as $dir_id) {
    $title_n = "New Manager Request";
    $message = "A new request ('" . $title . "') requires your approval.";
    $data = json_encode(["request_id" => $request_id, "type" => $request_type]);

    $stmt2 = mysqli_prepare($conn, "INSERT INTO notifications (user_id, sender_id, title, message, data, is_read) VALUES (?, ?, ?, ?, ?, 0)");
    mysqli_stmt_bind_param($stmt2, 'iisss', $dir_id, $manager_id, $title_n, $message, $data);
    mysqli_stmt_execute($stmt2);
    mysqli_stmt_close($stmt2);
}

echo json_encode(["success" => true, "message" => "Request created", "request_id" => $request_id]);

?>
