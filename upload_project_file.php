<?php
include "config.php";

// Get POST data
$project_id = $_POST['project_id'] ?? 0;

// Check if file is uploaded
if (!isset($_FILES['file'])) {
    echo json_encode([
        "success" => false,
        "message" => "No file uploaded"
    ]);
    exit;
}

$project_id = intval($project_id);

/* Validate project exists */
if ($project_id == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Missing project_id"
    ]);
    exit;
}

$verify_query = "SELECT id FROM projects WHERE id=$project_id";
$verify_result = mysqli_query($conn, $verify_query);

if (mysqli_num_rows($verify_result) == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Project not found"
    ]);
    exit;
}

/* Handle file upload */
$file = $_FILES['file'];
$allowed_types = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'image/jpeg', 'image/png'];
$max_size = 5 * 1024 * 1024; // 5MB

// Validate file
if (!in_array($file['type'], $allowed_types)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid file type. Allowed: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG"
    ]);
    exit;
}

if ($file['size'] > $max_size) {
    echo json_encode([
        "success" => false,
        "message" => "File size exceeds 5MB limit"
    ]);
    exit;
}

// Create uploads directory if not exists
$upload_dir = "uploads/projects/";
if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}

// Generate unique filename
$file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$file_name = "project_" . $project_id . "_" . time() . "." . $file_extension;
$file_path = $upload_dir . $file_name;

// Move uploaded file
if (move_uploaded_file($file['tmp_name'], $file_path)) {
    // Insert file record into database
    $file_name_safe = mysqli_real_escape_string($conn, $file['name']);
    $file_path_safe = mysqli_real_escape_string($conn, $file_path);
    
    $insert_file_query = "INSERT INTO project_files (project_id, file_name, file_path) 
    VALUES ($project_id, '$file_name_safe', '$file_path_safe')";
    
    if (mysqli_query($conn, $insert_file_query)) {
        echo json_encode([
            "success" => true,
            "message" => "File uploaded successfully",
            "data" => [
                "file_id" => mysqli_insert_id($conn),
                "file_name" => $file['name'],
                "file_path" => $file_path,
                "uploaded_at" => date("Y-m-d H:i:s")
            ]
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Error saving file record: " . mysqli_error($conn)
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to upload file"
    ]);
}

mysqli_close($conn);
?>
