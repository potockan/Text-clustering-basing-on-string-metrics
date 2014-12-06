<?php

ini_set("memory_limit", 	"512M");

function prepare_string_or_NULL($s)
{
   if (is_null($s)) return "NULL";
   if (strlen($s)==0) return "NULL";
   $res = SQLite3::escapeString($s);
   return "'".$res."'";
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
	global $q;
	global $i;
	global $title;
	global $red;
	global $ns;
    global $text;
    global $current_tag;
    $name = $current_tag;
    $red1 = $red;
    switch ($name) {
    	case "PAGE":
    	
    		if($i > 0 && $i<100){
    			$q .= "(";
    			$q .= $ns;
    			$q .= ","; 
    			$q .= prepare_string_or_NULL($title);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($text);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($red);
    			$q .= "), "; 
    		}
    		
    		
    		
    		$i++;
    		print($i."\n");
    		if($i%101 == 0)
			{
				
				$q .= "(";
    			$q .= $ns;
    			$q .= ","; 
    			$q .= prepare_string_or_NULL($title);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($text);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($red);
    			$q .= ") ";
				$sql = "INSERT INTO wiki_raw (ns, title, text, redirect) VALUES $q";
		  		$db->exec($sql);
		  		print "Finished Item $title \n";
		  		$q="";
		  		$i = 1;
			}
			
			$title = "";
    		$ns = "";
    		$test = "";
    		$red = NULL;
		   	
			
	    case "TITLE":
			$title = $title.$data;
        	break;
        	
       case "NS":
       		$ns = $ns.$data;
            break;
            
	   case "TEXT":
			$text = $text.$data;
			break;
	    
		
         
    }
    
    
    
}

function start_tag($parser, $name, $attr)
{

	global $current_tag;
	global $red;
	$current_tag = $name;
	if(array_key_exists("TITLE",$attr))
	{
		$red = $attr['TITLE'];
	
	}
}

function end_tag($parser, $name) 
{
    $current_tag = '';
}





$xml_parser = xml_parser_create();
$file = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml';
$i = 0;
$q = "";

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
    
   
	xml_set_element_handler($xml_parser, "start_tag", "end_tag");	
	if($current_tag == 'PAGE' || $current_tag == 'TITLE' ||  $current_tag == 'NS' ||  $current_tag == 'REDIRECT')
	{
	print("character_data\n");
	xml_set_character_data_handler($xml_parser, "contents");
	}
	
	

    	
}
	$q .= "(";
	$q .= $ns;
	$q .= ","; 
	$q .= prepare_string_or_NULL($title);
	$q .= ",";
	$q .= prepare_string_or_NULL($text);
	$q .= ",";
	$q .= prepare_string_or_NULL($red);
	$q .= ") ";
//	$q = "$q ($ns, prepare_string_or_NULL($title), prepare_string_or_NULL($text), prepare_string_or_NULL($red)) ";
	$sql = "INSERT INTO wiki_raw (ns, title, text, redirect) VALUES " . $q;
	$db->exec($sql);
	print "Finished Item " . $title ."\n";
	$i = 0;
			
    


xml_parser_free($xml_parser);

$db->close();

?>
