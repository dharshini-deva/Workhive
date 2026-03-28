<?php
header("Content-Type: application/json");
include "config.php";

/* Allow only GET */
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode([
        "success" => false,
        "message" => "GET method required"
    ]);
    exit;
}

/* Fetch only pending leaves */
$sql = "SELECT 
    lr.id,
    lr.user_id,
    u.full_name AS employee_name,
    lr.leave_type,
    lr.start_date,
    lr.end_date,
    lr.duration,
    lr.reason,
    lr.status,
    lr.created_at
FROM leave_requests lr
JOIN users u ON u.id = lr.user_id
ORDER BY lr.created_at DESC";

$result = mysqli_query($conn, $sql);

$leaves = [];

while ($row = mysqli_fetch_assoc($result)) {
    $leaves[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $leaves
]);
?>
