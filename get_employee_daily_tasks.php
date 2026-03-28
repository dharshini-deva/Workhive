<?php
include "config.php";
header("Content-Type: application/json");

// Input: employee_id, date (optional, defaults to today)
$employee_id = $_GET['employee_id'] ?? 0;
$date = $_GET['date'] ?? date('Y-m-d'); // Default to today

if (empty($employee_id)) {
    echo json_encode(["success" => false, "message" => "Missing employee_id"]);
    exit;
}

// Fetch daily tasks for the employee on the specific date
// We join with projects table to get project title
$query = "
    SELECT 
        dt.id,
        dt.task_name,
        dt.status,
        dt.description,
        dt.created_at,
        p.title as project_title
    FROM daily_tasks dt
    JOIN projects p ON dt.project_id = p.id
    WHERE dt.employee_id = ? 
    AND DATE(dt.created_at) = ?
    ORDER BY dt.created_at DESC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("is", $employee_id, $date);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode([
    "success" => true,
    "tasks" => $tasks
]);

$stmt->close();
$conn->close();
?>
