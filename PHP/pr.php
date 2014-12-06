<?php


function prepare_string_or_NULL($s)
{
   if (is_null($s)) return 'NULL';
   return "'".preg_replace("#'{1,}#","''",$s)."'";
}

class MyDB extends SQLite3
{
    function __construct()
    {
        $this -> open('/home/natalia/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite');
    }
}

$db = new MyDB();






function contents($parser, $data)
{
	global $db;
	global $i;
    //print ("contents\n");
    global $tabl;
    $tabl["red".$i] = NULL;
    global $current_tag;
    $name = $current_tag;
    //print($name."\n");
    switch ($name) {
    	case "PAGE":
    		$tabl["title".$i] = "";
    		$tabl["ns".$i] = "";
   			$tabl["text".$i] = "";
    		$i++;
    		//print($current_tag."\n");
    		print($i."\n");
    		print_r(array_keys($tabl));
    		print_r(array_values($tabl));
    		if($i%101 == 0)
			{
				//print("100!\n");
				$val = "";
				for($j = 1; $j<100; $j++)
				{
					$ns = $tabl["ns".$j];
					$title = prepare_string_or_NULL($tabl["title".$j]);
					print($tabl["title".$j]."\n");
					print($title."\n");
					$text = prepare_string_or_NULL($tabl["text".$j]) ;
					$redirect = prepare_string_or_NULL($tabl["red".$j]);
					//print($title."\n");
					if($j==99)
					{	$val = "$val ( $ns , $title, $text, $redirect ) "; }
					else
					{	$val = "$val ( $ns , $title, $text, $redirect ) , ";  }
				}
				
			$sql = "INSERT INTO wiki_raw (ns, title, text, redirect) VALUES " . $val;
	  		$db->exec($sql);
	  		print "Finished Item \n";
	  		unset($tabl);
	  		global $tabl;
	  		$i = 1;
			}
		   	$tabl["title".$i] = "";
    		$tabl["ns".$i] = "";
   			$tabl["text".$i] = "";
			
	    case "TITLE":
	    	//print("title\n");
			
			//print($i."\n");
			
			//print("title".$i."\n");
			$tabl["title".$i] = $tabl["title".$i].$data;
			//print($tabl["title".$i]);
			//print($data);
        	break;
       case "NS":
       		//print("ns".$i."\n");
       		//print("ns\n");
            $tabl["ns".$i] = $tabl["ns".$i] . $data;
            //print($data);
            break;
	   case "TEXT":
	   		//print("text".$i);
	   		//if($i>=0 && $i<=10)
	   		//{ print($data); }	   		
			$tabl["text".$i] = $tabl["text".$i] . $data;
			//$j=$i-1;
			//print($tabl["ns".$i]);
			break;
	    case "REDIRECT":
	    	//print("red".$i."\n");
			$tabl["red".$i] = $tabl["red".$i] . $data;
			break;
		
         
    }
    
    
    
}

function start_tag($parser, $name)
{
	//print ("start\n");
	global $current_tag;
	$current_tag = $name;
	//print($name."\n");
    
}

function end_tag($parser, $name) 
{
    //print ("end\n");
    $current_tag = $name;
    //$this->inside_data = false;
}





$xml_parser = xml_parser_create();
$file = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml';
$i = 0;

 if (!($fp = fopen($file, "r"))) 
 {
 	die("could not open XML input");
}

while ($data = fread($fp, 4096)) 
{

	if (!xml_parse($xml_parser, $data, feof($fp))) 
	{
		$error=xml_error_string(xml_get_error_code($xml_parser));
		$line=xml_get_current_line_number($xml_parser);
		die(sprintf("XML error: %s at line %d",$error,$line));
    }
    
    
    //print("elment handler\n");
	xml_set_element_handler($xml_parser, "start_tag", "end_tag");	
	if($current_tag == 'PAGE' || $current_tag == 'TITLE' ||  $current_tag == 'NS' ||  $current_tag == 'REDIRECT')
	{
	print("character_data\n");
	xml_set_character_data_handler($xml_parser, "contents");
	}
	
	

    	
}

				$val = "";
				for($j = 0; $j<$i; $j++)
				{
					$ns = $tabl["ns".$j];
					$title = prepare_string_or_NULL($tabl["title".$j]);
					$text = prepare_string_or_NULL($tabl["text".$j]);
					$redirect = prepare_string_or_NULL($tabl["red".$j]);
					if($j==$i-1)
					{	$val = "$val ( $ns , $title, $text, $redirect )  "; }
					else
					{	$val = "$val ( $ns , $title, $text, $redirect ) , ";  }
				}
			$sql = "INSERT INTO wiki_raw (ns, title, text, redirect) VALUES " . $val;
	  		$db->exec($sql);
	  		print "Finished Item " . $title ."\n";
	  		$i = 0;
			
    


xml_parser_free($xml_parser);

$db->close();

?>
