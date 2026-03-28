<?php
// get_notifications.php
// Returns notifications for a given user_id (most recent first)

include "config.php";

$user_id = 0;
if (isset($_GET['user_id'])) $user_id = intval($_GET['user_id']);
elseif (isset($_POST['user_id'])) $user_id = intval($_POST['user_id']);

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "Provide user_id"]);
    exit;
}

$tblCheck = mysqli_query($conn, "SHOW TABLES LIKE 'notifications'");
if (!$tblCheck || mysqli_num_rows($tblCheck) === 0) {
    echo json_encode(["success" => false, "message" => "Database table 'notifications' not found. Run create_leave_tables.sql to create required tables."]);
    exit;
}

// Check if sender_id column exists to avoid crash if schema not updated
$columnCheck = mysqli_query($conn, "SHOW COLUMNS FROM notifications LIKE 'sender_id'");
$hasSenderId = (mysqli_num_rows($columnCheck) > 0);

if ($hasSenderId) {
    $stmt = mysqli_prepare($conn, "
        SELECT n.id, n.title, n.message, n.data, n.is_read, n.created_at, u.profile_image 
        FROM notifications n
        LEFT JOIN users u ON n.sender_id = u.id
        WHERE n.user_id = ? 
        ORDER BY n.created_at DESC 
        LIMIT 100
    ");
} else {
    $stmt = mysqli_prepare($conn, "
        SELECT id, title, message, data, is_read, created_at, NULL as profile_image 
        FROM notifications 
        WHERE user_id = ? 
        ORDER BY created_at DESC 
        LIMIT 100
    ");
}

mysqli_stmt_bind_param($stmt, 'i', $user_id);
mysqli_stmt_execute($stmt);
mysqli_stmt_bind_result($stmt, $id, $title, $message, $data, $is_read, $created_at, $profile_image);

$baseUrl = "http://localhost/myworkhive/";

$rows = [];
while (mysqli_stmt_fetch($stmt)) {
    $rows[] = [
        'id' => $id,
        'title' => $title,
        'message' => $message,
        'data' => $data ? json_decode($data, true) : null,
        'is_read' => intval($is_read),
        'created_at' => $created_at,
        'profile_image' => $profile_image ? $baseUrl . $profile_image : null
    ];
}
mysqli_stmt_close($stmt);

echo json_encode(["success" => true, "notifications" => $rows]);

?>
