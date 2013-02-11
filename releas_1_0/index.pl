#!/usr/bin/perl

print "content-type: text/html \n\n";

#use warnings;
use DBI; #aby łączyć się z bazą
use CGI; #prosta obsługa POST, GET i HTML
my $cgi = CGI->new();

#Konfiguracja połączenia z mysql-em
$db = "adamek_svr219";
$passwd = "3K4#L0f*vgY";
#połączenie do mysql'a i utworzenie przypisania
$dbs = DBI->connect("dbi:mysql:$db", $db, $passwd) || die "Nie mozna połączyć siez bazą: $DBI::errstr";

#zmienne do porównań:
$htmlTitle = "";
$tableWordLists = "";
$errorCode = "";

#ładowanie języków:
	$query1 = "SELECT lcode, ldesc FROM lang";
	$query1_handle = $dbs->prepare($query1);
	$query1_handle->execute();
	$query1_handle->bind_columns(\$q1lcode, \$q1ldesc);
	$formLangList = "";
	while ($query1_handle->fetch()) {
		if ( $cgi->url_param('wordlang') and ( $cgi->url_param('wordlang') eq $q1lcode ) ) {
			$formLangList .= "<option value=\"$q1lcode\" selected=\"selected\">$q1ldesc</option>\n";
		} else {
			$formLangList .= "<option value=\"$q1lcode\">$q1ldesc</option>\n";
		}
	}

#wyświetlanie słów do tłumaczenia:
if ( $cgi->param('findWord') ) {
	if ( $cgi->param('findLang') and ( $cgi->param('findLang') ne "null" ) ) {
		$query_findWord = "SELECT id, word, lang, transof FROM words WHERE word = ? AND lang = ?";
		$handler_query_findWord = $dbs->prepare($query_findWord);
		if ( $handler_query_findWord->execute($cgi->param('findWord'), $cgi->param('findLang')) ) {
		} else {
			$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
		}
	} else {
		$query_findWord = "SELECT id, word, lang, transof FROM words WHERE word = ?";
		$handler_query_findWord = $dbs->prepare($query_findWord);
		if ( $handler_query_findWord->execute($cgi->param('findWord') ) ) {
		} else {
			$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
		}		
	}
	$handler_query_findWord->bind_columns(\$findWord_id, \$findWord_word, \$findWord_lang, \$findWord_transof);
	while ( $handler_query_findWord->fetch() ) {
		
		if ( $findWord_transof == 0 ) {
			#słowo bez tłumaczenia
			$tableWordLists .= "<li>$findWord_word ($findWord_lang) -> " . $cgi->a({href=>"admin.pl?action=tAdd&tId=$findWord_id&tLang=$findWord_lang"},"dodaj tłumaczenie") . " | " . $cgi->a({href=>"admin.pl?action=wEdit&wId=$findWord_id&wTransof=$findWord_transof&wLang=$findWord_lang"},"edytuj słowo") ." | ". $cgi->a({href=>"admin.pl?action=wDel&wId=$findWord_id&wTransof=$findWord_transof&wLang=$findWord_lang"},"usuń słowo") ."</li>";
		} else {
			if ( $findWord_transof == $findWord_id ) {
				#słowo główne z tłumaczeniem - wyświetlić tłumaczenia
				$tableWordLists .= "<li>$findWord_word ($findWord_lang) -> " . $cgi->a({href=>"admin.pl?action=tAdd&tId=$findWord_id&tLang=$findWord_lang"},"dodaj kolejne tłumaczenie") ." | " . $cgi->a({href=>"admin.pl?action=wEdit&wId=$findWord_id&wTransof=$findWord_transof&wLang=$findWord_lang"},"edytuj słowo") . " | " . $cgi->a({href=>"admin.pl?action=wDel&wId=$findWord_id&wTransof=$findWord_transof&wLang=$findWord_lang"},"usuń słowa");
				$query_findWordT = "SELECT id, word, lang, transof FROM words WHERE transof = ? AND id != ?";
				$handler_query_findWordT = $dbs->prepare($query_findWordT);
				if ( $handler_query_findWordT->execute($findWord_transof,  $findWord_id) ) {
					$handler_query_findWordT->bind_columns(\$findWordT_id, \$findWordT_word, \$findWordT_lang, \$findWordT_transof);
					$tableWordLists .= "<ul>\n";
					while ($handler_query_findWordT->fetch() ) {
						$tableWordLists .= "<li>$findWordT_word ($findWordT_lang) - ".$cgi->a({href=>"admin.pl?action=tEdit&tId=$findWordT_id&tLang=$findWordT_lang"},"zmień tłumaczenie")." | ". $cgi->a({href=>"admin.pl?action=wDel&wId=$findWordT_id&wTransof=$findWordT_transof&wLang=$findWordT_lang"},"usuń tłumaczenie") ."</li>\n";
					}
					$tableWordLists .= "</ul>\n";
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
				$tableWordLists .= "</li>\n";
			} else {

			#słowo tłumaczone
#				$query_findWordT2 = "SELECT id, word, lang, transof FROM words WHERE id = ?";
#				$handler_query_findWordT2 = $dbs->prepare($query_findWordT2);
#				if ( $handler_query_findWordT2->execute($findWord_transof) ) {
#					$handler_query_findWordT2->bind_columns(\$findWordT2_id, \$findWordT2_word, \$findWordT2_lang, \$findWordT2_transof);
#					while ( $handler_query_findWordT2->fetch() ) {
#						$tableWordLists .= "\n<tr>\n<td>$findWord_word</td>\n<td>$findWord_lang</td>\n<td>$findWordT2_word</td>\n<td>$findWordT2_lang</td>\n<td>edytuj tłumaczenie</td>\n</tr>\n";
#					}
#				} else {
#					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
#				}
			}
		}
	}
	
	
}
	
#HTML-e
$htmlTitle = "Słownik by Adamek -> ";
if ( $cgi->param('findWord') and ($cgi->param('findWord') ne "") ) {
	$htmlTitle .= $cgi->param('findWord');
} else {
	$htmlTitle .= "brak słowa.";
}

if ( $errorCode ne "") {
	$errorCode .= "\n<hr />\n";
}

#prasowanie HTML-a
open HTML, "tpl/wynik.html" or die $!;
	while (<HTML>) {
		s{<!-- htmlTitle -->}{$htmlTitle}; #<title>
		s{<!-- formLangList -->}{$formLangList}; #<select> -> <option>
		s{<!-- tableWordLists -->}{$tableWordLists}; #lista wyników
		s{<!-- errorCode -->}{$errorCode}; #wyświetlanie komunikatów
		print;
	}	
close HTML;

$dbs->disconnect;
