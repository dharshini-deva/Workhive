<?php
// config.php

$host = "localhost";
$user = "root";          // change if needed
$password = "";          // change if needed
$dbname = "workhive";

$conn = mysqli_connect($host, $user, $password, $dbname);

if (!$conn) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]);
    exit;
}
?>