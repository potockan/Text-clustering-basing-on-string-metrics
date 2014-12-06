<?php



//$is_final = false;

//xml_set_element_handler($parser, 'start_tag', 'end_tag');
//xml_set_character_data_handler($xml_parser, "contents");

//xml_parse($parser, '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml');


class xmltodb{

var $tabl = array();
var $parser;
var $data;
var $current_tag = 'page';
var $i = 0;
var $name = 'page';
var $inside_data = true;




protected function contents($parser, $data)
{
    switch ($this->current_tag) {
            case "ns":
                $tabl["ns".$this->$i] = $data;
                break;
	    case "text":
		$tabl["text".$this->$i] = $data;
		break;
	    case "redirect":
		$tabl["red".$this->$i] = $data;
		break;
		
         
    }
    if($this->$i%100 == 0)
    {
	print("100!\n");
	$this->$i = 0;
    }
    $this->$i++;
    $this->inside_data = true;
}

protected function start_tag($parser, $name)
{
    $this->current_tag = $name;
    $this->inside_data = false;
}

protected function end_tag($parser, $name) {
    $this->current_tag = $name;
    $this->inside_data = false;
}

//xml_set_element_handler($this->$parser, "start_tag", "end_tag");
//xml_set_character_data_handler($this->$parser, "contents");

}

$parser = xml_parser_create();
$doc ='/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1-1000lines.xml';
$objXML = new xmltodb();
$objXML -> parser = $parser;
$objXML -> data = $doc;
$file = $doc;

 if (!($fp = fopen($file, "r"))) 
{
    die("could not open XML input");
}

while ($data = fread($fp, 4096)) 
{
        if (!xml_parse($xml_parser, $objXML->data, feof($fp))) 
	{

		$error=xml_error_string(xml_get_error_code($parser));

		$line=xml_get_current_line_number($parser);
		die(sprintf("XML error: %s at line %d",$error,$line));
        }
}

xml_parser_free($parser);

 

?>



