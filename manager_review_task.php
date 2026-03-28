<?php
include "config.php";
header("Content-Type: application/json");

$task_id   = intval($_POST['task_id'] ?? 0);
$status    = $_POST['status'] ?? ''; // approved / rejected
$comment   = $_POST['comment'] ?? '';
$manager_id = intval($_POST['manager_id'] ?? 0);

if (!$task_id || !$status || !$manager_id) {
    echo json_encode(["success" => false, "message" => "Missing parameters"]);
    exit;
}

// 1. Update task status
$stmt = $conn->prepare("UPDATE daily_tasks SET manager_status=?, manager_comment=? WHERE id=?");
$stmt->bind_param("ssi", $status, $comment, $task_id);
if ($stmt->execute()) {
    
    // 2. Fetch employee_id and task_name to notify
    $fetchStmt = $conn->prepare("SELECT employee_id, task_name FROM daily_tasks WHERE id=?");
    $fetchStmt->bind_param("i", $task_id);
    $fetchStmt->execute();
    $fetchStmt->bind_result($employee_id, $task_name);
    
    if ($fetchStmt->fetch()) {
        $fetchStmt->close(); // Close before next query
        
        // 3. Create notification for employee
        $notifTitle   = "Task " . ucfirst($status);
        $notifMessage = "Your task '$task_name' has been $status by your manager.";
        if ($comment) $notifMessage .= " Comment: $comment";
        
        // Check if sender_id exists
        $colCheck = mysqli_query($conn, "SHOW COLUMNS FROM notifications LIKE 'sender_id'");
        if (mysqli_num_rows($colCheck) > 0) {
            $notifStmt = $conn->prepare("INSERT INTO notifications (user_id, sender_id, title, message, is_read) VALUES (?, ?, ?, ?, 0)");
            $notifStmt->bind_param("iiss", $employee_id, $manager_id, $notifTitle, $notifMessage);
        } else {
            $notifStmt = $conn->prepare("INSERT INTO notifications (user_id, title, message, is_read) VALUES (?, ?, ?, 0)");
            $notifStmt->bind_param("iss", $employee_id, $notifTitle, $notifMessage);
        }
        $notifStmt->execute();
        $notifStmt->close();
    } else {
        $fetchStmt->close();
    }
    
    echo json_encode(["success" => true, "message" => "Task reviewed and employee notified"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update task"]);
}
