<?php
include "config.php";
header("Content-Type: application/json");

// Expected inputs: project_id, employee_id, task_name, status, description
$project_id = $_POST['project_id'] ?? 0;
$employee_id = $_POST['employee_id'] ?? 0;
$task_name = $_POST['task_name'] ?? '';
$status = $_POST['status'] ?? 'In Progress'; // Default
$description = $_POST['description'] ?? '';

// Basic Validation
if (empty($project_id) || empty($employee_id) || empty($task_name)) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

// 1. Insert into daily_tasks table
// Assuming table structure from manager_get_pending_tasks.php usage:
// daily_tasks (project_id, employee_id, task_name, status, description, manager_status, created_at)
// manager_status likely defaults to 'pending'

$stmt = $conn->prepare("INSERT INTO daily_tasks (project_id, employee_id, task_name, status, description, manager_status, created_at) VALUES (?, ?, ?, ?, ?, 'pending', NOW())");
$stmt->bind_param("iisss", $project_id, $employee_id, $task_name, $status, $description);

if ($stmt->execute()) {
    
    // 2. IMPORTANT: Update the PROJECT STATUS if the user marks it as completed (or in progress)
    // The user specifically complained "progress bar is static".
    // This implies the project status drives the progress bar.
    
    // Update projects table
    // projects table likely has 'status' column (checked in get_employee_projects.php)
    
    $update_stmt = $conn->prepare("UPDATE projects SET status = ? WHERE id = ?");
    $update_stmt->bind_param("si", $status, $project_id);
    $update_stmt->execute();
    
    echo json_encode(["success" => true, "message" => "Daily task added and project status updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error adding task: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>
