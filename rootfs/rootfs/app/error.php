<?php
$containername = gethostname();
if (getenv("CONTAINERNAME") !== false ) {
$containername = getenv("CONTAINERNAME");
}
?>
<html>
<head>
<title>Error on <?php echo $containername;?></title>
</head>
<body>
<?php
echo "<b>An error has occured on $containername.</b><br>";
echo "Unique error ID: ".md5($containername.uniqid());
?>
</body>
</html>
