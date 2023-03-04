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
        <td style="{$td_style}">{$std_word_next}</td> 
        <td style="{$td_style}">{1}</td> </tr> )
        else ((: Return nothing otherwise :))
};

(: Recursive local function that keeps track of total occurence of a specific word with a counter :)
(: Function takes in a string word, the current index and totaloccurence of that word as an integer :)
declare function local:findTotalOccurence($value as xs:string?, $fileIndex as xs:integer?, $totalOccurence as xs:integer?)
{   (: Recursion ends when we work backwards from the size of the collection of XML files and hit 0 :)
    if ($fileIndex = 0)
    then ($totalOccurence) (: Once we run index out of fileindex scope we return all the occurences of the word we found :)
    else (
        let $words := ($files[$fileIndex])//w (: All our words are all <w> nodes in the file at $fileIndex in collection $files :)
        (: The newOccurence value is all the times that the specific word occurs in <w> nodes + the previous occurence of it on last recusrive call :)
        let $newOccurence := count($words[local:normaliseWord(.) = $value]) + $totalOccurence
        (: Since the condition has not been met of index = 0 we take -1 away, feed in the totaloccurence and do another recursive call :)
        return (local:findTotalOccurence($value, $fileIndex - 1, $newOccurence))
       )
};

(: This function takes in a table and returns an ordered probability table of it :)
declare function local:returnProbabilityTable($out)
{
   (: Selecting all distinct successor words :)
   for $value in distinct-values($out/td[2])
       (: $count is the amount of times that the successor word is found as the second td :)
       let $count := count($out/td[2][. eq $value])
       (: Total occurence function takes in the word, the size of the file collection and starting occurence :)
       let $total := local:findTotalOccurence($value, count($files), 0)
       (: Probabilit is the total occurence divided by total occurence formatted to 2 decimal points :)
       let $prob := (format-number($count div $total, "0.00"))
       (: Ordering by the count from most commonly occuring to least :)
       order by $prob descending
       (: It is known that td[1] was "has" so we just insert "has" regardless into the first td :)
       return <tr> 
       <td style="{$td_style}">{"has"}</td> 
       <td style="{$td_style}">{$value}</td> 
       <td style="{$td_style}">{$prob}</td> 
       </tr>
};

(: This simply returns $amount of nodes from the $table :)
declare function local:limitedOutput($table, $amount)
{   (: Return less than equal to $amount nodes :)
    $table[position() le $amount]
};

(: Starting point for the XQuery :)
declare function local:start()
{
(: Three table column headings for target and successor in HTML are below styled along with the table tag node itself :)
(: CSS Was applied in-line to conform to Coursework 1.pdf figures of table. :)
<table style="{$table_style}"> 
<tr> 
<th style="{$th_style}">Target</th> 
<th style="{$th_style}">Successor</th>
<th style="{$th_style}">Probability</th> 
</tr>
{       (: First populate the table :)
        let $table := local:populateTable()
        (: Then order it and tranform into a probability table :)
        let $outWithProb := local:returnProbabilityTable($table)
        (: Then reinput the prob table into a limiter function to output x amount of nodes. :)
        let $limitedOutput := local:limitedOutput($outWithProb, 20)
        (: Return the limited output :)
        return $limitedOutput
}
</table> (: End of HTML table :)
};

(: Start XQuery local function start() :)
local:start()



