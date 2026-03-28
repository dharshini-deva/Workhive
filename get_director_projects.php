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

if (!mysqli_stmt_fetch($check)) {
    echo json_encode([
        "success" => false,
        "message" => "Director not found"
    ]);
    exit;
}
mysqli_stmt_close($check);

if (strtolower(trim($role)) !== 'director') {
    echo json_encode([
        "success" => false,
        "message" => "Access denied"
    ]);
    exit;
}

/* =========================
   FETCH PROJECTS (DIRECTOR)
========================= */
/* =========================
   FETCH PROJECTS (DIRECTOR)
========================= */
$sql = "
SELECT
    p.id,
    p.title,
    p.status,
    p.deadline,
    p.created_at,

    u.full_name AS owner_name,

    COUNT(DISTINCT t.id) AS teams_count
FROM projects p
LEFT JOIN users u ON u.id = p.manager_id
LEFT JOIN teams t ON t.project_id = p.id
GROUP BY p.id
ORDER BY p.created_at DESC
";


$result = mysqli_query($conn, $sql);

$projects = [];
while ($row = mysqli_fetch_assoc($result)) {
    $projects[] = [
        "id" => (int)$row['id'],
        "title" => $row['title'],
        "status" => $row['status'],
        "deadline" => $row['deadline'],
        "created_at" => $row['created_at'],
        "owner_name" => $row['owner_name'] ?? "-",
        "teams_count" => (int)$row['teams_count']
    ];
}

echo json_encode([
    "success" => true,
    "projects" => $projects
]);

