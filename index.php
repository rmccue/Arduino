<?php
if(!file_exists('settings.json')) {
	file_put_contents('settings.json', json_encode(array('location' => '', 'frequency' => 10, 'last_update' => 0)));
}
$settings = file_get_contents('settings.json');
$settings = json_decode($settings);

if(isset($_POST['submit'])) {
	$settings->location = preg_replace('/[^A-Za-z0-9]/', '', $_POST['location']);
	$settings->frequency = (int) $_POST['frequency'];
	file_put_contents('settings.json', json_encode($settings));
}

$next = ($settings->last_update + ($settings->frequency * 60) );
?>
<!doctype html>
<html>
<head>
	<title>Weather Alerter</title>

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
	<script src="frontend/jquery.timeago.js"></script>
	<script src="frontend/date.js"></script>
	<script>
		update = function () {
			$("#status").load("frontend/update.php", {}, function () {
				now = new Date();
				$("#last-update").attr("title", now.toISOString()).text(now.toString("h:mm")).timeago();
			});
		};
		$(document).ready(function() {
			jQuery.timeago.settings.allowFuture = true;
			$('abbr[class*=timeago]').timeago();
			<?php
			if(time() > $next) {
			?>
			update();
			<?php
			}
			?>
			setInterval(update, <?php echo $settings->frequency * 60000 ?>);
		});
	</script>
</head>
<body>
	<h1>Weather Alerter</h1>
	<h2>Settings</h2>
	<form action="index.php" method="POST">
		<label for="location">Location Code: <input type="text" name="location" id="location" value="<?php echo $settings->location ?>" /></label>
		<label for="frequency">Frequency: <select name="frequency">
			<option value="5" <?php if($settings->frequency == 5) echo ' selected'; ?>>5 minutes</option>
			<option value="10" <?php if($settings->frequency == 10) echo ' selected'; ?>>10 minutes</option>
			<option value="30" <?php if($settings->frequency == 30) echo ' selected'; ?>>30 minutes</option>
			<option value="60" <?php if($settings->frequency == 60) echo ' selected'; ?>>1 hour</option>
		</select></label>
		<input type="submit" name="submit" value="Submit" />
	</form>
	<h2>Status</h2>
	<?php
		if($settings->last_update == 0) {
	?>
	<p>Last Update: <abbr id="last-update">never</abbr></p>
	<?php
		}
		else {
	?>
	<p>Last Update: <abbr title="<?php echo date('c', $settings->last_update) ?>" class="timeago" id="last-update"><?php echo date('g:i', $settings->last_update); ?></abbr></p>
	<?php
		}
	?>
	<p>Status: <span id="status">None</span></p>
	<p>Next Update: <abbr title="<?php echo date('c', $next) ?>" id="next-update" class="timeago"><?php echo date('g:i', $next); ?></abbr>
</body>
</html>