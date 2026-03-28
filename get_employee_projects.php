<?php
header("Content-Type: application/json");
include "config.php";

// Get employee_id
$employee_id = $_POST['employee_id'] ?? $_GET['employee_id'] ?? 0;

if (!$employee_id) {
    echo json_encode([
        "success" => false,
        "message" => "Missing employee_id"
    ]);
    exit;
}

$employee_id = intval($employee_id);

/* Verify employee exists */
$verify = mysqli_query(
    $conn,
    "SELECT id FROM users WHERE id = $employee_id AND role = 'Employee' AND is_active = 1"
);

if (!$verify || mysqli_num_rows($verify) === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid employee_id"
    ]);
    exit;
}

/* Fetch ONLY projects assigned to this employee */
$query = "
SELECT DISTINCT
    p.id,
    p.title,
    p.deadline,
    p.review_on,
    p.status

FROM team_members tm
JOIN teams t 
     ON tm.team_id = t.id
JOIN projects p 
     ON t.project_id = p.id



WHERE tm.user_id = $employee_id

ORDER BY p.deadline ASC
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

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = [
        "id" => $row['id'],
        "title" => $row['title'],
        "deadline" => $row['deadline'],
        "review_on" => $row['review_on'],
        "status" => $row['status'],
        
    ];
}

echo json_encode([
    "success" => true,
    "message" => "Employee projects fetched successfully",
    "data" => $data,
    "total_count" => count($data)
]);

mysqli_close($conn);
