<?php
include "config.php";

// Accept project_id / manager_id from GET or POST
$project_id = isset($_REQUEST['project_id']) ? intval($_REQUEST['project_id']) : 0;
$manager_id = isset($_REQUEST['manager_id']) ? intval($_REQUEST['manager_id']) : 0; // optional: fetch teams created by this manager

if ($project_id == 0 && $manager_id == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Provide either project_id or manager_id"
    ]);
    exit;
}

$where = [];
if ($project_id) $where[] = "t.project_id=" . intval($project_id);
if ($manager_id) $where[] = "t.created_by=" . intval($manager_id);
$where_sql = implode(' OR ', $where);

$query = "SELECT t.id, t.project_id, t.name, t.created_by, t.created_at FROM teams t WHERE ($where_sql) ORDER BY t.created_at DESC";
$res = mysqli_query($conn, $query);
if (!$res) {
    echo json_encode(["success" => false, "message" => "Database error: " . mysqli_error($conn)]);
    exit;
}

$teams = [];
while ($t = mysqli_fetch_assoc($res)) {
    $team_id = intval($t['id']);
    $members_q = "SELECT u.id, u.full_name, u.email, tm.team_role FROM team_members tm JOIN users u ON tm.user_id=u.id WHERE tm.team_id=$team_id";
    $mres = mysqli_query($conn, $members_q);
    $managers_out = [];
    $members_out = [];
    while ($m = mysqli_fetch_assoc($mres)) {
        if ($m['team_role'] === 'manager') $managers_out[] = $m;
        else $members_out[] = $m;
    }

    $teams[] = [
        "id" => $team_id,
        "project_id" => intval($t['project_id']),
        "name" => $t['name'],
        "created_by" => intval($t['created_by']),
        "created_at" => $t['created_at'],
        "managers" => $managers_out,
        "members" => $members_out
    ];
}

echo json_encode([
    "success" => true,
    "message" => "Teams fetched successfully",
    "total_count" => count($teams),
    "data" => $teams
]);

mysqli_close($conn);
?>