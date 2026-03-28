<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
include "config.php";

/* =========================
   INPUT
========================= */
$director_id = intval($_GET['director_id'] ?? $_POST['director_id'] ?? 0);

if ($director_id === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Provide director_id"
    ]);
    exit;
}

/* =========================
   VERIFY DIRECTOR
========================= */
$check = mysqli_prepare(
    $conn,
    "SELECT role FROM users WHERE id = ? AND is_active = 1 LIMIT 1"
);
mysqli_stmt_bind_param($check, "i", $director_id);
mysqli_stmt_execute($check);
mysqli_stmt_bind_result($check, $role);

if (!mysqli_stmt_fetch($check) || strtolower(trim($role)) !== 'director') {
    echo json_encode([
        "success" => false,
        "message" => "Access denied"
    ]);
    exit;
}
mysqli_stmt_close($check);

/* =========================
   FETCH TEAMS (DIRECTOR)
========================= */
$sql = "
SELECT
    t.id AS team_id,
    t.name AS team_name,
    t.project_id,
    p.title AS project_title,
    p.status AS project_status,

    u.full_name AS manager_name,

    COUNT(DISTINCT tm.user_id) AS team_size
FROM teams t
LEFT JOIN projects p ON p.id = t.project_id
LEFT JOIN users u ON u.id = t.created_by
LEFT JOIN team_members tm ON tm.team_id = t.id
GROUP BY t.id
ORDER BY t.created_at DESC
";

$result = mysqli_query($conn, $sql);

$teams = [];
while ($row = mysqli_fetch_assoc($result)) {
    $teams[] = [
        "team_id" => (int)$row['team_id'],
        "team_name" => $row['team_name'],
        "project_id" => (int)$row['project_id'],
        "project_title" => $row['project_title'],
        "project_status" => $row['project_status'],
        "manager_name" => $row['manager_name'] ?? "-",
        "team_size" => (int)$row['team_size']
    ];
}

echo json_encode([
    "success" => true,
    "teams" => $teams
]);
