<?php
require_once('simplepie.inc');
$settings = file_get_contents('../settings.json');
$settings = json_decode($settings);
$settings->last_update = time();
file_put_contents('../settings.json', json_encode($settings));
$sp = new SimplePie();
$sp->set_cache_location('./cache');
$sp->set_cache_duration($settings->frequency * 60);
$sp->set_feed_url('http://xml.weather.yahoo.com/forecastrss?p=' . $settings->location . '&u=c');
$sp->init();

if(stripos($sp->get_title(), 'error')) {
	die('Invalid location');
}

$item = $sp->get_item();
$weather = $item->get_item_tags('http://xml.weather.yahoo.com/ns/rss/1.0', 'forecast');
$weather = $weather[0]['attribs'][''];
$today = array();
$today[] = $weather['low'];
$today[] = $weather['high'];

// Cloudy conditions
if($weather['code'] > 25 && $weather['code'] < 31) {
	$today[] = 'C';
}
elseif($weather['code'] > 30 && $weather['code'] < 35) {
	$today[] = 'F';
}
else {
	$today[] = 'S';
}

file_put_contents('../weather.txt', implode(',', $today));
echo shell_exec('cd .. & python arduino.py 2> err.txt');