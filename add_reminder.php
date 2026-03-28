<?php
// create_reminder.php  (JSON INPUT)

include "config.php";
header("Content-Type: application/json");

// 🔴 DEBUG (remove in production)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 📥 Read JSON body
$data = json_decode(file_get_contents("php://input"), true);

// ❌ Invalid JSON
if (!$data) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid JSON payload"
    ]);
    exit;
}

// 🔐 Validate required fields
if (
    empty($data['user_id']) ||
    empty($data['title']) ||
    empty($data['start_date']) ||
    empty($data['start_time']) ||
    empty($data['end_time'])
) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields"
    ]);
    exit;
}

// ✅ Sanitize inputs
$user_id     = intval($data['user_id']);
$title       = mysqli_real_escape_string($conn, trim($data['title']));
$description = mysqli_real_escape_string($conn, trim($data['description'] ?? ""));

// Dates & Times
$start_date  = $data['start_date'];   // yyyy-mm-dd
$end_date    = !empty($data['end_date']) ? $data['end_date'] : $start_date; // ✅ Custom End Date
$start_time  = $data['start_time'];   // HH:mm:ss
$end_time    = $data['end_time'];

// Optional fields
$day_id = isset($data['day_id']) && intval($data['day_id']) > 0
            ? intval($data['day_id'])
            : 0;

$repeat_everyday = isset($data['repeat_everyday'])
                    ? intval($data['repeat_everyday'])
                    : 0;

// 📝 SQL Insert
$sql = "
    INSERT INTO reminders
    (
        user_id,
        title,
        description,
        start_date,
        end_date,
        start_time,
        end_time,
        day_id,
        repeat_everyday
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
";

$stmt = mysqli_prepare($conn, $sql);

// ❌ SQL prepare failed
if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "SQL prepare failed: " . mysqli_error($conn)
    ]);
    exit;
}

// 🔗 Bind params
mysqli_stmt_bind_param(
    $stmt,
    "issssssii",
    $user_id,
    $title,
    $description,
    $start_date,
    $end_date,
    $start_time,
    $end_time,
    $day_id,
    $repeat_everyday
);

// ▶️ Execute
if (mysqli_stmt_execute($stmt)) {
    echo json_encode([
        "success" => true,
        "message" => "Reminder created successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Insert failed: " . mysqli_stmt_error($stmt)
    ]);
}

// 🧹 Cleanup
mysqli_stmt_close($stmt);
mysqli_close($conn);
