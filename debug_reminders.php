<?php
include "config.php";

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
    echo "Prepare failed: " . mysqli_error($conn);
    exit;
}

$user_id = 1; // Test user ID
mysqli_stmt_bind_param($stmt, "i", $user_id);
mysqli_stmt_execute($stmt);

$result = mysqli_stmt_get_result($stmt);
if (!$result) {
    echo "Execute failed: " . mysqli_error($conn);
    exit;
}

while ($row = mysqli_fetch_assoc($result)) {
    print_r($row);
    echo "<br>";
}

mysqli_stmt_close($stmt);
mysqli_close($conn);
?>
