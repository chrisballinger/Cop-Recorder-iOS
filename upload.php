<?php
$uploaddir = './uploads/';
$file = basename($_FILES['userfile']['name']);
$uploadfile = $uploaddir . $file;

if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile)) {
        echo "YES";
}
else {
		echo "NO";
}
?>