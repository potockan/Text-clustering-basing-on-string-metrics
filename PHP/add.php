<?php

function prepare_string_or_NULL($s)
{
   if (is_null($s)) return 'NULL';
   return "'".preg_replace("'{1,}","''",$s)."'";
}

class MyDB extends SQLite3
{
    function __construct()
    {
        $this -> open('/home/natalia/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite');
    }
}

$db = new MyDB();

$xml_file = new XMLReader;
$xml_file -> open('/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1-1000lines.xml');

$doc = new DOMDocument;

// move to the first <page> node
while ($xml_file -> read() && $xml_file -> name !== 'page');

$i = 0;
while ($xml_file -> read())
{
  $xml_file -> read();
  if ($xml_file -> nodeType == XMLReader::ELEMENT && $xml_file -> name == 'page') {
	$xml_file -> moveToElement('title');
	  
	  $title = $xml_file -> readString(); //wywala wszystko z page'a bez tagów
	  
	  print "$title \n";
	  print "tu jeden";
	  $title = $xml_file -> value;
	  print "$title \n";
	  print "tu drugi";
	
	

	  
	 
	  print "Finished Item $i \n";
  }
    $i = $i +1;

    $xml_file -> next('page');
}




$db -> close();
?>
