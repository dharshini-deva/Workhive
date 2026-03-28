<?php
include "config.php";

// Function to check if a column exists
function columnExists($conn, $table, $column) {
    $result = $conn->query("SHOW COLUMNS FROM $table LIKE '$column'");
    return $result && $result->num_rows > 0;
}

// 1. Create daily_tasks table if not exists
$create_table_sql = "
CREATE TABLE IF NOT EXISTS daily_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'In Progress',
    manager_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (employee_id) REFERENCES users(id)
)";

if ($conn->query($create_table_sql) === TRUE) {
    echo "Table 'daily_tasks' checked/created successfully.<br>";
} else {
    echo "Error creating table: " . $conn->error . "<br>";
}

// 2. Check and Add Missing Columns
$columns_to_check = [
    'description' => "TEXT",
    'status' => "VARCHAR(50) DEFAULT 'In Progress'",
    'manager_status' => "VARCHAR(50) DEFAULT 'pending'",
    'task_name' => "VARCHAR(255) NOT NULL"
];

foreach ($columns_to_check as $col => $def) {
    if (!columnExists($conn, 'daily_tasks', $col)) {
        $alter_sql = "ALTER TABLE daily_tasks ADD COLUMN $col $def";
        if ($conn->query($alter_sql) === TRUE) {
            echo "Added column '$col' to 'daily_tasks'.<br>";
        } else {
            echo "Error adding column '$col': " . $conn->error . "<br>";
        }
    } else {
        echo "Column '$col' already exists.<br>";
    }
}

// 3. Ensure 'status' column exists in 'projects' table (for progress tracking)
if (!columnExists($conn, 'projects', 'status')) {
    $alter_sql = "ALTER TABLE projects ADD COLUMN status VARCHAR(50) DEFAULT 'In Progress'";
    if ($conn->query($alter_sql) === TRUE) {
        echo "Added column 'status' to 'projects'.<br>";
    } else {
        echo "Error adding column 'status' to 'projects': " . $conn->error . "<br>";
    }
} else {
    echo "Column 'status' already exists in 'projects'.<br>";
}

echo "<h3>Database Schema Fix Complete.</h3>";
$conn->close();
?>
