<?php



//$is_final = false;

//xml_set_element_handler($parser, 'start_tag', 'end_tag');
//xml_set_character_data_handler($xml_parser, "contents");

//xml_parse($parser, '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml');


//$inside_data = true;




function contents($parser, $data)
{
    print ("contents\n");
    $tabl["red".$i] = NULL;
    switch ($this->current_tag) {
	    case "title":
		$tabl["title".$i] = $data;
                break;
            case "ns":
                $tabl["ns".$i] = $data;
                break;
	    case "text":
		$tabl["text".$i] = $data;
		break;
	    case "redirect":
		$tabl["red".$i] = $data;
		break;
		
         
    }
    $i++;
    if($i%100 == 0)
    {
	print("100!\n");
	$i = 0;
    }
    
    
}

function start_tag($parser, $name)
{
    print ("start\n");
    $current_tag = $name;
    //$this->inside_data = false;
}

function end_tag($parser, $name) 
{
    print ("end\n");
    $current_tag = $name;
    //$this->inside_data = false;
}





$parser = xml_parser_create();
/*$doc ='/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml';
$is_final = false;
//$file = $doc;
$name = 'page';
$i = 0;
$tabl = array();
$current_tag = 'page';
$i = 0;
*/

print("open\n");

/* if (!($fp = fopen($doc, "r"))) 
{
    die("could not open XML input");
}
*/
print(xml_parse($parser, '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml'));

while (xml_parse($parser, $doc, $is_final))
{

	print("xml_parse\n");
        if (!xml_parse($parser, $doc, feof($fp))) 
	{

		$error=xml_error_string(xml_get_error_code($parser));

		$line=xml_get_current_line_number($parser);
		die(sprintf("XML error: %s at line %d",$error,$line));
        }
	
print("elment handler\n");
xml_set_element_handler($parser, "start_tag", "end_tag");
print("character_data\n");
xml_set_character_data_handler($parser, "contents");

}

xml_parser_free($parser);



?>



