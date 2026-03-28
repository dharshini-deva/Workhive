<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
include "config.php";

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$team_id = intval($_GET['team_id'] ?? 0);

if ($team_id === 0) {
    echo json_encode([
        "success" => false,
        "message" => "team_id required"
    ]);
    exit;
}

/* =========================
   TEAM + PROJECT
========================= */
$teamRes = mysqli_query($conn, "
    SELECT
        t.name AS team_name,
        p.title AS project_title,
        p.status AS project_status
    FROM teams t
    LEFT JOIN projects p ON p.id = t.project_id
    WHERE t.id = $team_id
    LIMIT 1
");

$team = mysqli_fetch_assoc($teamRes);

if (!$team) {
    echo json_encode([
        "success" => false,
        "message" => "Team not found"
    ]);
    exit;
}

/* =========================
   MANAGERS
========================= */
$managers = [];

$mgrRes = mysqli_query($conn, "
    SELECT
        u.id,
        u.full_name,
        u.profile_image
    FROM team_members tm
    JOIN users u ON u.id = tm.user_id
    WHERE tm.team_id = $team_id
      AND tm.team_role = 'manager'
");

while ($row = mysqli_fetch_assoc($mgrRes)) {
    $managers[] = [
        "id"    => (int)$row['id'],
        "name"  => $row['full_name'],
        "role"  => "Manager",
        "image" => $row['profile_image']
    ];
}

/* =========================
   MEMBERS
========================= */
$members = [];

$memRes = mysqli_query($conn, "
    SELECT
        u.id,
        u.full_name,
        u.profile_image
    FROM team_members tm
    JOIN users u ON u.id = tm.user_id
    WHERE tm.team_id = $team_id
      AND tm.team_role = 'member'
");

while ($row = mysqli_fetch_assoc($memRes)) {
    $members[] = [
        "id"    => (int)$row['id'],
        "name"  => $row['full_name'],
        "role"  => "Member",
        "image" => $row['profile_image']
    ];
}

/* =========================
   RESPONSE
========================= */
echo json_encode([
    "success"         => true,
    "team_name"      => $team['team_name'],
    "project_title"  => $team['project_title'],
    "project_status" => $team['project_status'],
    "managers"       => $managers,
    "members"        => $members
]);
