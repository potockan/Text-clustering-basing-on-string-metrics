<?php



class MyDB extends SQLite3
{
    function __construct()
    {
        $this -> open('/home/natalia/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite');
    }
}

$db = new MyDB();


$sql = "VACUUM";
$db->exec($sql);


$db->close();

?>
