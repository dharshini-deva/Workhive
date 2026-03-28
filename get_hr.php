<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include "config.php";
header("Content-Type: application/json");

$employee_id = $_GET['employee_id'] ?? null;

try {

    // ===============================
    // CASE 1: FETCH SINGLE PROFILE
    // ===============================
    if (!empty($employee_id)) {

        $stmt = $conn->prepare("
            SELECT 
                id,
                full_name,
                email,
                phone,
                role,
                profile_image,
                is_active,
                created_at
            FROM users
            WHERE id = ?
            LIMIT 1
        ");

        $stmt->bind_param("i", $employee_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($row = $result->fetch_assoc()) {

            $row['status_text'] = ($row['is_active'] == 1) ? 'Active' : 'Inactive';

            echo json_encode([
                "success" => true,
                "type" => "single",
                "data" => $row
            ]);
            exit;
        }

        echo json_encode([
            "success" => false,
            "message" => "Employee not found"
        ]);
        exit;
    }

    // ===============================
    // CASE 2: FETCH PROFILE LIST
    // ===============================
    $stmt = $conn->prepare("
        SELECT 
            id,
            full_name,
            email,
            phone,
            role,
            profile_image,
            is_active,
            created_at
        FROM users
        WHERE role IN ('employee', 'manager')
        ORDER BY role, full_name
    ");

    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {

        $row['status_text'] = ($row['is_active'] == 1) ? 'Active' : 'Inactive';

        // IMPORTANT: profile_image returned AS-IS
        $data[] = $row;
    }

    echo json_encode([
        "success" => true,
        "type" => "list",
        "count" => count($data),
        "data" => $data
    ]);

} catch (Throwable $e) {

    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
