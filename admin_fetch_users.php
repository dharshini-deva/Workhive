<?php
include "config.php";
header("Content-Type: application/json");

$sql = "
    SELECT 
        id,
        full_name,
        role,
        phone,
        email
    FROM users
    WHERE role IN ('admin','manager','employee','hr','director')
    ORDER BY full_name ASC
";

$result = mysqli_query($conn, $sql);

$users = [];

while ($row = mysqli_fetch_assoc($result)) {
    $users[] = $row;
}

echo json_encode($users);
