<?php


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
    //print ("contents\n");
    //$tabl["red".$i] = NULL;
    global $current_tag;
    $name = $current_tag;
    //print($name."\n");
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
    			//print($q);
 
    		}
    		
    		
    		$i++;
    		print($i."\n");
    		//print_r(array_keys($tabl));
    		//print_r(array_values($tabl));
    		if($i%101 == 0)
			{
				//print("100!\n");
				if($i == 17)
				{print($red);}
				//print($q."\n");
				$q .= "(";
    			$q .= $ns;
    			$q .= ","; 
    			$q .= prepare_string_or_NULL($title);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($text);
    			$q .= ",";
    			$q .= prepare_string_or_NULL($red);
    			$q .= ") ";
				//$q = "$q ($ns, prepare_string_or_NULL($title), prepare_string_or_NULL($text), prepare_string_or_NULL($red)) ";
				//print($q);	
				$sql = "INSERT INTO wiki_raw (ns, title, text, redirect) VALUES $q";
				//print($sql);
		  		$db->exec($sql);
		  		print "Finished Item $title \n";
		  		//unset($tabl);
		  		//global $tabl;
		  		$q="";
		  		$i = 1;
			}
			
			$title = "";
    		$ns = "";
    		$test = "";
		   	
			
	    case "TITLE":
	    	//print("title\n");
			
			//print($i."\n");
			
			//print("title".$i."\n");
			$title = $title.$data;
			//print($tabl["title".$i]);
			//print($data);
        	break;
       case "NS":
       		//print("ns".$i."\n");
       		//print("ns\n");
            $ns = $ns.$data;
            //print($data);
            break;
	   case "TEXT":
	   		//print("text".$i);
	   		//if($i>=0 && $i<=10)
	   		//{ print($data); }	   		
			$text = $text.$data;
			//$j=$i-1;
			//print($tabl["ns".$i]);
			break;
	    
		
         
    }
    
    
    
}

function start_tag($parser, $name, $attr)
{
	//print ("start\n");
	global $current_tag;
	global $red;
	$red=NULL;
	$current_tag = $name;
	if($name == "REDIRECT");
	{
		print_r($attr);
		$red = $attr[0]['TITLE'];
		print($red);
	
	}
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
    
    
    //print("elment handler\n");
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
