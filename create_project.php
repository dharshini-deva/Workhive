<?php
include "config.php";

// Get POST data
$manager_id = intval($_POST['manager_id'] ?? 0);
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$deadline = $_POST['deadline'] ?? '';
$review_on = $_POST['review_on'] ?? '';
$budget = $_POST['budget'] ?? '';

/* Validate required fields */
if ($manager_id == 0 || empty($title) || empty($description)) {
    echo json_encode([
        "success" => false,
        "message" => "Missing required fields: manager_id, title, description"
    ]);
    exit;
}

// /* =========================
//    DUPLICATE PROJECT CHECK
// ========================= */
// $check = $conn->prepare(
//     "SELECT id FROM projects 
//      WHERE title = ? AND manager_id = ? AND is_active = 1 
//      LIMIT 1"
// );
// $check->bind_param("si", $title, $manager_id);
// $check->execute();
// $check->store_result();

// if ($check->num_rows > 0) {
//     echo json_encode([
//         "success" => false,
//         "message" => "Project already exists"
//     ]);
//     exit;
// }
// $check->close();

/* Verify manager exists and has manager role */
$manager_id = intval($manager_id);
$verify_query = "SELECT id FROM users WHERE id=$manager_id AND role='Manager' AND is_active=1";
$verify_result = mysqli_query($conn, $verify_query);

if (mysqli_num_rows($verify_result) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid manager_id or user is not a Manager"
    ]);
    exit;
}

/* Sanitize inputs */
$title = mysqli_real_escape_string($conn, trim($title));
$description = mysqli_real_escape_string($conn, trim($description));
$deadline = mysqli_real_escape_string($conn, trim($deadline));
$review_on = mysqli_real_escape_string($conn, trim($review_on));
$budget = mysqli_real_escape_string($conn, trim($budget));

/* Insert project into database */
$insert_query = "INSERT INTO projects (manager_id, title, description, deadline, review_on, budget, status) 
VALUES ($manager_id, '$title', '$description', '$deadline', '$review_on', '$budget', 'Active')";

if (mysqli_query($conn, $insert_query)) {
    $project_id = mysqli_insert_id($conn);

echo json_encode([
    "success" => true,
    "message" => "Project created successfully",
    "project" => [
        "project_id" => $project_id,
        "manager_id" => $manager_id,
        "title" => $title,
        "description" => $description,
        "deadline" => $deadline,
        "review_on" => $review_on,
        "budget" => $budget,
        "status" => "Active",
        "created_at" => date("Y-m-d H:i:s")
    ]
]);

} else {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . mysqli_error($conn)
    ]);
}

mysqli_close($conn);
?>
