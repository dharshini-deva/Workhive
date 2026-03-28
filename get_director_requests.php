<?php
// get_director_requests.php
ini_set('display_errors', 1);
error_reporting(E_ALL);
header("Content-Type: application/json");
include "config.php";

if (!$conn) {
    echo json_encode(["success" => false, "message" => "DB connection failed"]);
    exit;
}

mysqli_set_charset($conn, "utf8mb4");

/* INPUT */
$status = strtolower(trim($_GET['status'] ?? 'pending'));
$limit  = intval($_GET['limit'] ?? 100);
if ($limit <= 0) $limit = 100;

/* FETCH REQUESTS */
$sql = "
SELECT
    mr.id,
    mr.manager_id,
    u.full_name AS manager_name,
    mr.project_id,
    mr.title,
    mr.request_type,
    mr.details,
    mr.value,
    mr.status,
    mr.created_at
FROM manager_requests mr
JOIN users u ON u.id = mr.manager_id
WHERE LOWER(mr.status) = ?
ORDER BY mr.created_at DESC
LIMIT ?
";

$stmt = mysqli_prepare($conn, $sql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => mysqli_error($conn)]);
    exit;
}

mysqli_stmt_bind_param($stmt, "si", $status, $limit);
mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);
$rows = [];

while ($row = mysqli_fetch_assoc($result)) {
    $rows[] = $row;
}

mysqli_stmt_close($stmt);

echo json_encode([
    "success" => true,
    "count" => count($rows),
    "requests" => $rows
]);
