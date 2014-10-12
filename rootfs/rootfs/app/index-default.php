<?php
$containername = gethostname();
if (getenv("CONTAINERNAME") !== false ) {
$containername = getenv("CONTAINERNAME");
}
?>
<html>
<head>
<title>Web App on <?php echo $containername;?></title>
</head>
<body>
<?php
// $pipaddress = getenv('HTTP_X_FORWARDED_FOR');
$ipaddress = getenv('REMOTE_ADDR');
$remoteport = getenv('REMOTE_PORT');
echo "<b>You are connected to $containername.</b><br>";
echo "Your IP address is: $ipaddress:$remoteport<br><br>";
// echo "HTTP_X_FORWARDED_FOR: $pipaddress<br>";
echo "Cookies: ";
foreach($_COOKIE as $name => $value) {
echo "$name: $value<br>";
}
echo "<br>HTTP headers: ";
foreach (getallheaders() as $name => $value) {
echo "$name: $value<br>";
}
?>

</body>
</html>
