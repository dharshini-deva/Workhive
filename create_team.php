<?php
include "config.php";

// Get POST data
$creator_id = $_POST['creator_id'] ?? 0; // manager creating the team
$project_id = $_POST['project_id'] ?? 0;
$team_name = $_POST['team_name'] ?? '';
$managers = $_POST['managers'] ?? ''; // can be JSON array string or CSV
$members = $_POST['members'] ?? '';  // can be JSON array string or CSV

if ($creator_id == 0 || $project_id == 0 || empty($team_name)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields: creator_id, project_id, team_name"
    ]);
    exit;
}

$creator_id = intval($creator_id);
$project_id = intval($project_id);
$team_name = mysqli_real_escape_string($conn, trim($team_name));

// Verify creator exists and is a manager
$verify_query = "SELECT id FROM users WHERE id=$creator_id AND role='Manager' AND is_active=1";
$verify_result = mysqli_query($conn, $verify_query);
if (!$verify_result || mysqli_num_rows($verify_result) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid creator_id or user is not a Manager"
    ]);
    exit;
}

// Verify project exists and belongs to this manager (optional safety)
$proj_query = "SELECT id FROM projects WHERE id=$project_id AND manager_id=$creator_id";
$proj_result = mysqli_query($conn, $proj_query);
if (!$proj_result || mysqli_num_rows($proj_result) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Project not found or does not belong to this manager"
    ]);
    exit;
}

// Helper to parse incoming list (accepts JSON array, CSV, or repeated form fields)
function parseUserList($input) {
    if (is_array($input)) return array_map('intval', $input);
    $input = trim($input);
    if ($input === '') return [];
    // try JSON
    $decoded = json_decode($input, true);
    if (is_array($decoded)) return array_map('intval', $decoded);
    // else CSV
    $parts = preg_split('/[,;\s]+/', $input);
    return array_map('intval', array_filter($parts, function($v){ return $v !== ''; }));
}

$manager_ids = parseUserList($managers);
$member_ids = parseUserList($members);

// Validate that all managers have 'Manager' role
foreach ($manager_ids as $mid) {
    $check_q = "SELECT id FROM users WHERE id=$mid AND role='Manager' AND is_active=1";
    $check_r = mysqli_query($conn, $check_q);
    if (!$check_r || mysqli_num_rows($check_r) == 0) {
        echo json_encode([
            "success" => false,
            "message" => "User ID $mid is not a Manager or is inactive"
        ]);
        exit;
    }
}

// Validate that all members have 'Employe' role
foreach ($member_ids as $uid) {
    $check_q = "SELECT id FROM users WHERE id=$uid AND role='Employee' AND is_active=1";
    $check_r = mysqli_query($conn, $check_q);
    if (!$check_r || mysqli_num_rows($check_r) == 0) {
        echo json_encode([
            "success" => false,
            "message" => "User ID $uid is not an Employee or is inactive"
        ]);
        exit;
    }
}

// Start transaction
mysqli_begin_transaction($conn);

$insert_team_sql = "INSERT INTO teams (project_id, name, created_by) VALUES ($project_id, '$team_name', $creator_id)";
if (!mysqli_query($conn, $insert_team_sql)) {
    mysqli_rollback($conn);
    echo json_encode(["success" => false, "message" => "Failed to create team: " . mysqli_error($conn)]);
    exit;
}

$team_id = mysqli_insert_id($conn);

// Function to insert members
function insertTeamMember($conn, $team_id, $user_id, $role) {
    $team_id = intval($team_id);
    $user_id = intval($user_id);
    if ($user_id == 0) return true; // skip invalid ids silently
    $sql = "INSERT INTO team_members (team_id, user_id, team_role) VALUES ($team_id, $user_id, '$role')";
    return mysqli_query($conn, $sql);
}

// Insert managers
foreach ($manager_ids as $mid) {
    if (!insertTeamMember($conn, $team_id, $mid, 'manager')) {
        mysqli_rollback($conn);
        echo json_encode(["success" => false, "message" => "Failed to add manager $mid: " . mysqli_error($conn)]);
        exit;
    }
}

// Insert members
foreach ($member_ids as $uid) {
    if (!insertTeamMember($conn, $team_id, $uid, 'member')) {
        mysqli_rollback($conn);
        echo json_encode(["success" => false, "message" => "Failed to add member $uid: " . mysqli_error($conn)]);
        exit;
    }
}

mysqli_commit($conn);

// Build response: fetch inserted team and its members
$team_q = "SELECT id, project_id, name, created_by, created_at FROM teams WHERE id=$team_id";
$team_res = mysqli_query($conn, $team_q);
$team = mysqli_fetch_assoc($team_res);

$members_q = "
SELECT 
    u.id,
    u.full_name,
    u.email,
    u.profile_image,
    tm.team_role
FROM team_members tm
JOIN users u ON tm.user_id = u.id
WHERE tm.team_id = $team_id
";

$members_res = mysqli_query($conn, $members_q);
$managers_out = [];
$members_out = [];

while ($r = mysqli_fetch_assoc($members_res)) {

    $user = [
        "id" => (int)$r['id'],                 // ✅ FIX
        "full_name" => $r['full_name'],
        "email" => $r['email'],
        "team_role" => $r['team_role'],
        "profile_image" => $r['profile_image'] ?: null
    ];

    if ($r['team_role'] === 'manager') {
        $managers_out[] = $user;
    } else {
        $members_out[] = $user;
    }
}


echo json_encode([
    "success" => true,
    "message" => "Team created successfully",
    "data" => [
        "team_id" => intval($team['id']),
        "project_id" => intval($team['project_id']),
        "name" => $team['name'],
        "created_by" => intval($team['created_by']),
        "created_at" => $team['created_at'],
        "managers" => $managers_out,
        "members" => $members_out
    ]
]);

mysqli_close($conn);
?>