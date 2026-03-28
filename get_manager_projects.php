<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
include "config.php";

/* =========================
   INPUT
========================= */
$manager_id = 0;
if (isset($_GET['manager_id'])) {
    $manager_id = intval($_GET['manager_id']);
} elseif (isset($_POST['manager_id'])) {
    $manager_id = intval($_POST['manager_id']);
}

if ($manager_id === 0) {
    echo json_encode(["success" => false, "message" => "Provide manager_id"]);
    exit;
}

/* =========================
   VERIFY MANAGER
========================= */
$manCheck = mysqli_prepare(
    $conn,
    "SELECT role FROM users WHERE id = ? AND is_active = 1 LIMIT 1"
);

mysqli_stmt_bind_param($manCheck, 'i', $manager_id);
mysqli_stmt_execute($manCheck);
mysqli_stmt_bind_result($manCheck, $man_role);

if (!mysqli_stmt_fetch($manCheck)) {
    mysqli_stmt_close($manCheck);
    echo json_encode(["success" => false, "message" => "Manager not found"]);
    exit;
}
mysqli_stmt_close($manCheck);

if (strtolower(trim($man_role)) !== 'manager') {
    echo json_encode([
        "success" => false,
        "message" => "Only Manager can view projects"
    ]);
    exit;
}

/* =========================
   FETCH PROJECTS (STEP 1)
========================= */
$query = "
SELECT 
    id,
    manager_id,
    title,
    description,
    deadline,
    review_on,
    budget,
    status,
    created_at,
    updated_at
FROM projects
WHERE manager_id = ?
ORDER BY created_at DESC
";

$stmt = mysqli_prepare($conn, $query);
mysqli_stmt_bind_param($stmt, 'i', $manager_id);
mysqli_stmt_execute($stmt);
mysqli_stmt_bind_result(
    $stmt,
    $id,
    $mid,
    $title,
    $description,
    $deadline,
    $review_on,
    $budget,
    $status,
    $created_at,
    $updated_at
);

$projects = [];

while (mysqli_stmt_fetch($stmt)) {
    $projects[] = [
        "id" => $id,
        "manager_id" => $mid,
        "title" => $title,
        "description" => $description,
        "deadline" => $deadline,
        "review_on" => $review_on,
        "budget" => $budget,
        "status" => $status,
        "created_at" => $created_at,
        "updated_at" => $updated_at
    ];
}

mysqli_stmt_close($stmt); // ✅ VERY IMPORTANT

/* =========================
   TEAM & MEMBER COUNT (STEP 2)
========================= */
foreach ($projects as &$project) {

    // Team count
    $teamCount = 0;
    $t = mysqli_prepare($conn, "SELECT COUNT(*) FROM teams WHERE project_id = ?");
    mysqli_stmt_bind_param($t, 'i', $project['id']);
    mysqli_stmt_execute($t);
    mysqli_stmt_bind_result($t, $teamCount);
    mysqli_stmt_fetch($t);
    mysqli_stmt_close($t);

    // Member count
    $memberCount = 0;
    $m = mysqli_prepare(
        $conn,
        "SELECT COUNT(DISTINCT tm.user_id)
         FROM team_members tm
         JOIN teams t ON tm.team_id = t.id
         WHERE t.project_id = ?"
    );
    mysqli_stmt_bind_param($m, 'i', $project['id']);
    mysqli_stmt_execute($m);
    mysqli_stmt_bind_result($m, $memberCount);
    mysqli_stmt_fetch($m);
    mysqli_stmt_close($m);

    $project['team_count'] = $teamCount;
    $project['member_count'] = $memberCount;
}
unset($project);

/* =========================
   RESPONSE
========================= */
echo json_encode([
    "success" => true,
    "manager_id" => $manager_id,
    "projects" => $projects
]);
