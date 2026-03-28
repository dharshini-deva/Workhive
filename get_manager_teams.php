<?php
include "config.php";
header("Content-Type: application/json");

$manager_id = intval($_GET['manager_id'] ?? 0);

if ($manager_id === 0) {
    echo json_encode([
        "success" => false,
        "message" => "manager_id required"
    ]);
    exit;
}

$query = "
SELECT
    t.id AS team_id,
    t.name AS team_name,
    p.title AS project_title,
    p.status AS project_status,
    u.full_name AS manager_name,
    COUNT(tm.user_id) AS team_size
FROM teams t
LEFT JOIN projects p ON p.id = t.project_id
LEFT JOIN team_members tm ON tm.team_id = t.id
LEFT JOIN users u ON u.id = t.created_by
WHERE t.created_by = ?
GROUP BY t.id
ORDER BY t.created_at DESC
";

$stmt = mysqli_prepare($conn, $query);
mysqli_stmt_bind_param($stmt, "i", $manager_id);
mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);

$teams = [];
while ($row = mysqli_fetch_assoc($result)) {
    $teams[] = $row;
}

echo json_encode([
    "success" => true,
    "teams" => $teams
]);
