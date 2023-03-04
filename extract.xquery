(: Putting all current xml_files folder xml files into a single collection :)
declare variable $files := collection('xml_files/?select=*.xml');

(: Declaring variables for table, th and td styling that will hold the relevant CSS stylings :)
declare variable $table_style as xs:string := "border:1px solid black; border-collapse: collapse; text-align: center";
declare variable $th_style as xs:string := "border:1px solid black; border-collapse: collapse; font-weight:normal; font-style:italic; padding:1px 5px;";
declare variable $td_style as xs:string := "border: 1px solid black; border-collapse: collapse;";

(: Shorthand function to normalise words :)
declare function local:normaliseWord($word)
{   (: Get the data from given node, lowercase it and then remove whitespace :)
    normalize-space(lower-case(data($word)))
};

(: Function which returns the populated cells in HTML :)
declare function local:populateTable()
{
for $file in $files (: Iterate over each XML file in the XML file collection :)
let $words := $file//w (: All <w> nodes found in the file are taken :)
    for $word at $index in $words (: Iterating over every <w> node in $words at $index counter :)
     let $std_word := local:normaliseWord($word) (: Normalise the current word :)
     let $std_word_next := local:normaliseWord($words[$index + 1]) (: Normalise the word after through index + 1 :)
     (: Return if current word target = "has" and the word after it if conditional is true :)
     return if ($std_word = "has") then (
        (: Return stylised HTML rows with cells respectively containing target and successor :)
        <tr> <td style="{$td_style}">{$std_word}</td> 
        <td style="{$td_style}">{$std_word_next}</td> </tr> )
        else ((: Return nothing otherwise :))
};

(: Starting point for the XQuery :)
declare function local:start()
{
(: Two table column headings for target and successor in HTML are below styled along with the table tag node itself :)
(: CSS Was applied in-line to conform to Coursework 1.pdf figures of table. :)
<table style="{$table_style}"> 
<tr> 
<th style="{$th_style}">Target</th> 
<th style="{$th_style}">Successor</th> 
</tr>
{   (: Let the table cells to be present inside the HTML table be the result of the local populateTable function :)
    let $outputCells := local:populateTable()
    return $outputCells
}
</table> (: End of HTML table :)
};

(: Start XQuery local function start() :)
local:start()