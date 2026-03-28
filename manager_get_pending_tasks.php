<?php
include "config.php";
header("Content-Type: application/json");

$manager_id = isset($_GET['manager_id']) ? intval($_GET['manager_id']) : 0;

if ($manager_id <= 0) {
    echo json_encode(["success" => false, "message" => "Invalid Manager ID"]);
    exit;
}

// Fetch pending tasks from projects managed by this manager
$query = "
    SELECT 
        dt.id,
        dt.task_name,
        dt.description,
        dt.status as task_status,
        dt.created_at,
        p.title as project_title,
        p.id as project_id,
        u.full_name as employee_name,
        u.id as employee_id
    FROM daily_tasks dt
    JOIN projects p ON dt.project_id = p.id
    JOIN users u ON dt.employee_id = u.id
    WHERE p.manager_id = ? 
    AND dt.manager_status = 'pending'
    ORDER BY dt.created_at DESC
";

$stmt = $conn->prepare($query);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    exit;
}

$stmt->bind_param("i", $manager_id);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode([
    "success" => true,
    "tasks" => $tasks,
    "count" => count($tasks)
]);

$stmt->close();
$conn->close();
?>
