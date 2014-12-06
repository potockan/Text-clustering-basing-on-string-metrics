<?php


$parser = xml_parser_create();
$doc ='/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1-1000lines.xml';
$is_final = false;
xml_set_element_handler($parser, '<page>', '</page>');

print(xml_parse($parser, '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml')."\n");

while(xml_parse($parser, $doc, $is_final))
{
	print('TAK!');
	$is_final = true;


}
/*
xml_set_character_data_handler($xml_parser, "contents");

xml_set_element_handler($this->parser, "start_tag", "end_tag");
xml_set_character_data_handler($this->parser, "contents");

protected function contents($parser, $data)
{
    switch ($this->current_tag) {
            case "name":
                if ($this->inside_data)
                    $this->name .= $data; // need to concatenate data
                else
                    $this->name = $data;
                break;
         ...
    }
    $this->inside_data = true;
}

protected function start_tag($parser, $name)
{
    $this->current_tag = $name;
    $this->inside_data = false;
}

protected function end_tag() {
    $this->current_tag = '';
    $this->inside_data = false;
}


 if (!($fp = fopen($file, "r"))) {
                        die("could not open XML input");
                }

                while ($data = fread($fp, 4096)) {
                        if (!xml_parse($xml_parser, $data, feof($fp))) {

$error=xml_error_string(xml_get_error_code($xml_parser));

$line=xml_get_current_line_number($xml_parser);
                                die(sprintf("XML error: %s at line %d",$error,$line));
                        }
                }

xml_parser_free($xml_parser);

*/

?>
