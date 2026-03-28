<?php
include "config.php";
header("Content-Type: application/json");

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if (!$user_id) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid user"
    ]);
    exit;
}

$sql = "
    SELECT 
        id,
        title,
        description,
        start_date,
        start_time,
        end_time,
        end_date,
        day_id,
        repeat_everyday
    FROM reminders
    WHERE user_id = ?
    ORDER BY start_date ASC, start_time ASC
";

$stmt = mysqli_prepare($conn, $sql);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "SQL Prepare failed: " . mysqli_error($conn)
    ]);
    exit;
}

mysqli_stmt_bind_param($stmt, "i", $user_id);
mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);

$reminders = [];

while ($row = mysqli_fetch_assoc($result)) {
    // Ensure end_date is not null
    if (empty($row['end_date'])) {
        $row['end_date'] = $row['start_date'];
    }
    $reminders[] = $row;
}

echo json_encode([
    "success" => true,
    "reminders" => $reminders
]);

mysqli_stmt_close($stmt);
mysqli_close($conn);
