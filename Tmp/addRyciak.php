<?php

function sqlQuoteOrNull($s)
{
   if (is_null($s)) return "NULL";
   return "'".str_replace("'","''",$s)."'";
}

class MyDB extends SQLite3
{
    function __construct()
    {
        $this->open('/media/sf_pub/PracaMagisterska/StackOverflow.db');
    }
}

$db = new MyDB();

$z = new XMLReader;
$z->open('/media/sf_pub/PracaMagisterska/Comments.xml');

$doc = new DOMDocument;

// move to the first <row> node
while ($z->read() && $z->name !== 'row');

$i = 0;
while ($z->read())
{
  $z->read();
  if ($z->nodeType == XMLReader::ELEMENT && $z->name == 'row') {
   
	  $Id = $z->getAttribute('Id');
	  $PostId  = $z->getAttribute('PostId');
	  $Score  = $z->getAttribute('Score');
	  $Text  = $z->getAttribute('Text');
	  $CreationDate  = $z->getAttribute('CreationDate');
	  $UserId  = $z->getAttribute('UserId');
	  $UserDisplayName  = $z->getAttribute('UserDisplayName');

	  $Text  = sqlQuoteOrNull($Text);
	  $CreationDate = sqlQuoteOrNull(str_replace("T"," ",$CreationDate));
	  $UserDisplayName = sqlQuoteOrNull($UserDisplayName);	

	  $sql = "INSERT INTO Comments (Id,PostId,Score,Text,CreationDate,UserId,UserDisplayName) VALUES ($Id, $PostId, $Score, $Text, $CreationDate, $UserId, $UserDisplayName)";
	  $db->exec($sql);
	  print "Finished Item $i: Id:$Id  /n";
  }
    $i = $i +1;

    $z->next('row');
}


$db->close();
?>
