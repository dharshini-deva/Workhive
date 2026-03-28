<?php
header("Content-Type: application/json");
include "config.php";

// Get POST data
$manager_id = $_POST['manager_id'] ?? 0;
$status = $_POST['status'] ?? 'Active';

// Validate
if ($manager_id == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Missing manager_id"
    ]);
    exit;
}

$manager_id = intval($manager_id);
$status = mysqli_real_escape_string($conn, trim($status));

/* Verify manager exists */
$verify_query = "
    SELECT id 
    FROM users 
    WHERE id = $manager_id 
      AND role = 'Manager' 
      AND is_active = 1
";
$verify_result = mysqli_query($conn, $verify_query);

if (!$verify_result || mysqli_num_rows($verify_result) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid manager_id"
    ]);
    exit;
}

/* Fetch projects with CORRECT assigned_count */
$query = "
SELECT 
    p.id,
    p.title,
    p.description,
    p.deadline,
    p.review_on,
    p.budget,
    p.status,
    p.created_at,
    p.updated_at,

    COUNT(DISTINCT tm.user_id) AS assigned_count,

    (
        SELECT COUNT(*) 
        FROM project_files pf 
        WHERE pf.project_id = p.id
    ) AS files_count

FROM projects p
LEFT JOIN teams t 
       ON t.project_id = p.id
LEFT JOIN team_members tm 
       ON tm.team_id = t.id

WHERE p.manager_id = $manager_id
";

/* Optional status filter */
if ($status !== '') {
    $query .= " AND p.status = '$status'";
}

$query .= "
GROUP BY p.id
ORDER BY p.created_at DESC
";

$result = mysqli_query($conn, $query);

if (!$result) {
    echo json_encode([
        "success" => false,
        "message" => "Database error",
        "error" => mysqli_error($conn)
    ]);
    exit;
}

/* Build response */
$projects = [];
while ($row = mysqli_fetch_assoc($result)) {
    $projects[] = [
        "id" => $row['id'],
        "title" => $row['title'],
        "description" => $row['description'],
        "deadline" => $row['deadline'],
        "review_on" => $row['review_on'],
        "budget" => $row['budget'],
        "status" => $row['status'],
        "assigned_count" => $row['assigned_count'],
        "files_count" => $row['files_count'],
        "created_at" => $row['created_at'],
        "updated_at" => $row['updated_at']
    ];
}

echo json_encode([
    "success" => true,
    "message" => "Projects fetched successfully",
    "data" => $projects,
    "total_count" => count($projects)
]);

mysqli_close($conn);
?>
