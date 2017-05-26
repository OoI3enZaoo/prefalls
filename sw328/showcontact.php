<?php
header('Access-Control-Allow-Origin: *'); 
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "sw328";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

$sql = "SELECT * FROM contact";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["id"]. " - Name: " . $row["name"]. " - company: " . $row["company"]. " - email: " . $row["email"]. "<br/>";
    }
} else {
    echo "0 results";
}
$conn->close();
?>