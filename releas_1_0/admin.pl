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
$dbs = DBI->connect("dbi:mysql:$db", $db, $passwd) || die "Nie mozna połączyć się z bazą: $DBI::errstr";

$errorCode = "";
$tableLanguagesList = "";
$WordLangOptions = "";
$LangAction = "Dodaj";
$WordAction = "Dodaj";
$WordAction2 = "do słownika w języku:";
$WordLang = "";
$tableWordLists = "";

#dodawanie słownika:
if ( $cgi->param('LangAction') and ( $cgi->param('LangAction') eq "LangAdd" ) ) {
	$query_LangAdd = "INSERT INTO lang SET lname = ?, lcode = ?, ldesc = ?";
	$handle_query_LangAdd = $dbs->prepare($query_LangAdd);
	if ($handle_query_LangAdd->execute($cgi->param('LangName'), $cgi->param('LangCode'), $cgi->param('LangDesc') ) ) {
		if ($handle_query_LangAdd->rows > 0) {
			$errorCode .= "Słownik \"" . $cgi->param('LangName') . "\" został pomyślnie dodany do bazy!";
		} else {
			$errorCode .= "UWAGA! Słownik \"" . $cgi->param('LangName') . "\" nie został pomyślnie dodany do bazy!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#edycja słownika:
if ( $cgi->param('LangAction') and ( $cgi->param('LangAction') eq "LangEdit" ) ) {
	$query_LangAdd = "UPDATE lang SET lname = ?, lcode = ?, ldesc = ? WHERE id = ?";
	$handle_query_LangAdd = $dbs->prepare($query_LangAdd);
	if ($handle_query_LangAdd->execute($cgi->param('LangName'), $cgi->param('LangCode'), $cgi->param('LangDesc'), $cgi->param('LangId') ) ) {
		if ($handle_query_LangAdd->rows > 0) {
			$errorCode .= "Słownik \"" . $cgi->param('LangName') . "\" został pomyślnie zmieniony!";
		} else {
			$errorCode .= "UWAGA! Słownik \"" . $cgi->param('LangName') . "\" nie został zmieniony!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#usuwanie słownika:
if ( $cgi->param('LangAction') and ( $cgi->param('LangAction') eq "LangDelete" ) ) {
	#usunąć również wszystkie powiązane ze słownikiem słowa!
	$query_LangAdd = "DELETE FROM lang WHERE id = ?";
	$handle_query_LangAdd = $dbs->prepare($query_LangAdd);
	if ($handle_query_LangAdd->execute( $cgi->param('LangId') ) ) {
		if ($handle_query_LangAdd->rows > 0) {
			$errorCode .= "Słownik \"" . $cgi->param('LangName') . "\" został pomyślnie usunięty!";
		} else {
			$errorCode .= "UWAGA! Słownik \"" . $cgi->param('LangName') . "\" nie został usunięty!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#dodawanie słowa:
if ( $cgi->param('WordAction') and ( $cgi->param('WordAction') eq "WordAdd" ) ) {
	$query_WordAdd = "INSERT INTO words SET word = ?, lang = ?, transof = 0";
	$handle_query_WordAdd = $dbs->prepare($query_WordAdd);
	if ($handle_query_WordAdd->execute($cgi->param('WordName'), $cgi->param('WordLang') ) ) {
		if ($handle_query_WordAdd->rows > 0) {
			$errorCode .= "Słowo \"" . $cgi->param('WordName') . "\" zostało pomyślnie dodane do słownika!";
		} else {
			$errorCode .= "UWAGA! Słowo \"" . $cgi->param('WordName') . "\" nie zostało dodane do słownika!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#dodawanie translacji: TransAdd

if ( $cgi->param('WordAction') and ( $cgi->param('WordAction') eq "TransAdd" ) ) {
	$query_TransAdd = "INSERT INTO words SET word = ?, lang = ?, transof = ?";
	$handle_query_TransAdd = $dbs->prepare($query_TransAdd);
	if ($handle_query_TransAdd->execute($cgi->param('WordName'), $cgi->param('WordLang'), $cgi->param('WordTransof') ) ) {
		if ($handle_query_TransAdd->rows > 0) {
			$query_TransAdd1 = "UPDATE words SET transof = ? WHERE id = ?";
			$handle_query_TransAdd1 = $dbs->prepare($query_TransAdd1);
			if ($handle_query_TransAdd1->execute($cgi->param('WordTransof'), $cgi->param('WordTransof') ) ) {
				$errorCode .= "Tłumaczenie słowa \"" . $cgi->param('WordName') . "\" zostało pomyślnie dodane do słownika!";
			} else {
				$errorCode .= "UWAGA! Tłumaczenie słowa \"" . $cgi->param('WordName') . "\" zostało dodane do słownika bez aktualizacji słowa bazowego!";
			}
		} else {
			$errorCode .= "UWAGA! Tłumaczenie słowa \"" . $cgi->param('WordName') . "\" nie zostało dodane do słownika!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#edycja słowa:
if ( $cgi->param('WordAction') and ( $cgi->param('WordAction') eq "WordEdit" ) ) {
	$query_WordEdit = "UPDATE words SET word = ?, lang = ?, transof = ? WHERE id = ?";
	$handle_query_WordEdit = $dbs->prepare($query_WordEdit);
	if ($handle_query_WordEdit->execute($cgi->param('WordName'), $cgi->param('WordLang'), $cgi->param('WordTransof'), $cgi->param('WordId') ) ) {
		if ($handle_query_WordEdit->rows > 0) {
			$errorCode .= "Słowo \"" . $cgi->param('WordName') . "\" zostało pomyślnie zmienione w słowniku!";
		} else {
			$errorCode .= "UWAGA! Słowo \"" . $cgi->param('WordName') . "\" nie zostało zmienione w słowniku!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#edycja tłumaczenia:
if ( $cgi->param('WordAction') and ( $cgi->param('WordAction') eq "TransEdit" ) ) {
	$query_WordEdit = "UPDATE words SET word = ?, lang = ?, transof = ? WHERE id = ?";
	$handle_query_WordEdit = $dbs->prepare($query_WordEdit);
	if ($handle_query_WordEdit->execute($cgi->param('WordName'), $cgi->param('WordLang'), $cgi->param('WordTransof'), $cgi->param('WordId') ) ) {
		if ($handle_query_WordEdit->rows > 0) {
			$errorCode .= "Tłumaczenie słowa \"" . $cgi->param('WordName') . "\" zostało pomyślnie zmienione w słowniku!";
		} else {
			$errorCode .= "UWAGA! Słowo \"" . $cgi->param('WordName') . "\" nie zostało zmienione w słowniku!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
	}
}

#usuwanie słowa:
if ( $cgi->param('WordAction') and ( $cgi->param('WordAction') eq "WordDelete" ) ) {
	if ( $cgi->param('WordTransof') == 0 ) {
		#pojedyńcze słowo bez tłumaczeń
		$query_WordDelete = "DELETE FROM words WHERE id = ?";
	} else {
		#słowo z tłumaczeniami, sprawdzić czy główne (transof = id) czy tłumaczenie
		if ( $cgi->param('WordId') == $cgi->param('WordTransof') ) {
			#główne słowo wywalamy wg transof
			$query_WordDelete = "DELETE FROM words WHERE transof = ?";
			$add_coment = " ze wszystkimi tłumaczeniami";
		} else {
			#tłumaczenie - wywalamy po id
			$query_WordDelete = "DELETE FROM words WHERE id = ?";
		}
	}
	$handle_query_WordDelete = $dbs->prepare($query_WordDelete);
	if ( $handle_query_WordDelete->execute($cgi->param('WordId') ) ) {
		if ($handle_query_WordDelete->rows > 0) {
			$errorCode .= "Słowo \"" . $cgi->param('WordName') . "\"" . $add_coment . " zostało pomyślnie usunięte ze słownika!";
		} else {
			$errorCode .= "UWAGA! Słowo \"" . $cgi->param('WordName') . "\" nie zostało usunięte ze słownika!";
		}		
	} else {
		$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
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

#			#słowo tłumaczone
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

#Wyświetlanie listy słowników:
$query_lang = "SELECT id, lcode, lname, ldesc FROM lang";
$handler_query_lang = $dbs->prepare($query_lang);
if ( $handler_query_lang->execute() ) {
	$handler_query_lang->bind_columns(\$lang_id, \$lang_lcode, \$lang_lname, \$lang_ldesc);
	$i=1;
	while ( $handler_query_lang->fetch() ) {
		$tableLanguagesList .= "<tr>\n<td>$i.</td>\n<td>$lang_lname</td>\n<td>$lang_lcode</td>\n<td>$lang_ldesc</td>\n<td>". $cgi->a({href=>"admin.pl?action=dEdit&dId=$lang_id"},"Edytuj") . " " . $cgi->a({href=>"admin.pl?action=dDel&dId=$lang_id"},"Usuń") . "</td>\n</tr>\n";
		$i++;
	}
} else {
	$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
}

#Wyświetlanie listy słowników do formularza:
$query_lang2 = "SELECT id, lcode, lname, ldesc FROM lang";
$handler_query_lang2 = $dbs->prepare($query_lang2);
if ( $handler_query_lang2->execute() ) {
	$handler_query_lang2->bind_columns(\$lang2_id, \$lang2_lcode, \$lang2_lname, \$lang2_ldesc);
	while ( $handler_query_lang2->fetch() ) {
		if ( ($cgi->url_param('wLang') and ($cgi->url_param('wLang') eq $lang2_lcode)) or ($cgi->url_param('tLang') and ($cgi->url_param('tLang') eq $lang2_lcode)) ) {
			$WordLangOptions .= "<option value=\"$lang2_lcode\" selected=\"selected\">$lang2_ldesc</option>";
		} else {
			$WordLangOptions .= "<option value=\"$lang2_lcode\">$lang2_ldesc</option>";
		}
	}
} else {
	$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
}

#prasowanie HTML-a
open HTML, "tpl/admin.html" or die $!;
	while (<HTML>) {	
	
		#SŁOWNIKI (dozwolone akcje: add, edit, delete)
		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "dDel" ) ) {
			#usuwanie słownika - wyświetlenie form z wypełnieniem
			if ( $cgi->url_param('dId') ) {
				$query_dDel = "SELECT id, lcode, lname, ldesc FROM lang WHERE id=?";
				$handler_query_dDel = $dbs->prepare($query_dDel);
				if ( $handler_query_dDel->execute( $cgi->url_param('dId') ) ) {
					$handler_query_dDel->bind_columns(\$dDel_id, \$dDel_lcode, \$dDel_lname, \$dDel_ldesc);
					if ($handler_query_dDel->fetch()) {
						$LangAction = "Usuń";
						s{name="LangAction" value="LangAdd"}{name="LangAction" value="LangDelete"};
						s{name="LangName"}{name="LangName" value="$dDel_lname"}; #nazwa jezyka
						s{name="LangCode"}{name="LangCode" value="$dDel_lcode"}; #kod języka
						s{name="LangDesc"}{name="LangDesc" value="$dDel_ldesc"}; #opis języka
						s{name="LangId"}{name="LangId" value="$dDel_id"};	
						$errorCode .= "Zostaną usunięte również wszystkie słowa powiązane ze słownikiem";
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}			
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słownika do usunięcia!\n";
			}
		}

		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "dEdit" ) ) {
			#edycja słownika - wyświetlenie form z wypełnieniem
			if ( $cgi->url_param('dId') ) {
				$query_dEdit = "SELECT id, lcode, lname, ldesc FROM lang WHERE id=?";
				$handler_query_dEdit = $dbs->prepare($query_dEdit);
				if ( $handler_query_dEdit->execute( $cgi->url_param('dId') ) ) {
					$handler_query_dEdit->bind_columns(\$dEdit_id, \$dEdit_lcode, \$dEdit_lname, \$dEdit_ldesc);
					if ($handler_query_dEdit->fetch()) {
						$LangAction = "Edytuj";
						s{name="LangAction" value="LangAdd"}{name="LangAction" value="LangEdit"};
						s{name="LangName"}{name="LangName" value="$dEdit_lname"}; #nazwa jezyka
						s{name="LangCode"}{name="LangCode" value="$dEdit_lcode"}; #kod języka
						s{name="LangDesc"}{name="LangDesc" value="$dEdit_ldesc"}; #opis języka
						s{name="LangId"}{name="LangId" value="$dEdit_id"};				
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}			
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słownika do edycji!\n";
			}
		}
		
		#SŁOWA:
		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "wDel" ) ) {
			#sprawdzić czy jest wordID i czy jest Transof
			if ( $cgi->url_param('wId') and $cgi->url_param('wLang') ) {
				$query_wDel = "SELECT id, word, lang, transof FROM words WHERE id=?";
				$handler_query_wDel = $dbs->prepare($query_wDel);
				if ( $handler_query_wDel->execute( $cgi->url_param('wId') ) ) {
					$handler_query_wDel->bind_columns(\$wDel_id, \$wDel_word, \$wDel_lang, \$wDel_transof);
					if ( $handler_query_wDel->fetch() ) {
						$WordAction = "Usuń";
						$WordAction2 = "znajdujące się w słowniku:";
						s{name="WordAction" value="WordAdd"}{name="WordAction" value="WordDelete"};
						s{name="WordName"}{name="WordName" value="$wDel_word"}; #słowo
						s{name="WordId"}{name="WordId" value="$wDel_id"}; #id słowa
						s{name="WordTransof"}{name="WordTransof" value="$wDel_transof"}; #translacja
						s{name="WordLang2"}{name="WordLang2" value="$wDel_lang"};							
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słowa do usunięcia!\n";
			}
		}

		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "wEdit" ) ) {
			#sprawdzić czy jest wordID i czy jest Transof
			if ( $cgi->url_param('wId') and $cgi->url_param('wLang') ) {
				$query_wEdit = "SELECT id, word, lang, transof FROM words WHERE id=?";
				$handler_query_wEdit = $dbs->prepare($query_wEdit);
				if ( $handler_query_wEdit->execute( $cgi->url_param('wId') ) ) {
					$handler_query_wEdit->bind_columns(\$wEdit_id, \$wEdit_word, \$wEdit_lang, \$wEdit_transof);
					if ( $handler_query_wEdit->fetch() ) {
						$WordAction = "Edytuj";
						$WordAction2 = "znajdujące się w słowniku:";
						s{name="WordAction" value="WordAdd"}{name="WordAction" value="WordEdit"};
						s{name="WordName"}{name="WordName" value="$wEdit_word"}; #słowo
						s{name="WordId"}{name="WordId" value="$wEdit_id"}; #id słowa
						s{name="WordTransof"}{name="WordTransof" value="$wEdit_transof"}; #translacja
						s{name="WordLang2"}{name="WordLang2" value="$wEdit_lang"};							
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słowa do edycji!\n";
			}		
		}
		
		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "tAdd" ) ) {
			#sprawdzić czy jest wordID i czy jest Transof
			if ( $cgi->url_param('tId') ) {
				$query_tAdd = "SELECT id, word, lang, transof FROM words WHERE id=?";
				$handler_query_tAdd = $dbs->prepare($query_tAdd);
				if ( $handler_query_tAdd->execute( $cgi->url_param('tId') ) ) {
					$handler_query_tAdd->bind_columns(\$tAdd_id, \$tAdd_word, \$tAdd_lang, \$tAdd_transof);
					if ( $handler_query_tAdd->fetch() ) {
						$WordAction = "Słowo \"$tAdd_word ($tAdd_lang)\" tłumaczy się na: ";
						$WordAction2 = "języku:";
						s{name="WordAction" value="WordAdd"}{name="WordAction" value="TransAdd"};
						s{name="WordTransof"}{name="WordTransof" value="$tAdd_id"}; #translacja
						s{name="WordLang2"}{name="WordLang2" value="$tAdd_lang"};							
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słowa do edycji!\n";
			}		
		}	
		
		if ( $cgi->url_param('action') and ( $cgi->url_param('action') eq "tEdit" ) ) {
			#sprawdzić czy jest wordID i czy jest Transof
			if ( $cgi->url_param('tId') and $cgi->url_param('tLang') ) {
				$query_tEdit = "SELECT id, word, lang, transof FROM words WHERE id=?";
				$handler_query_tEdit = $dbs->prepare($query_tEdit);
				if ( $handler_query_tEdit->execute( $cgi->url_param('tId') ) ) {
					$handler_query_tEdit->bind_columns(\$tEdit_id, \$tEdit_word, \$tEdit_lang, \$tEdit_transof);
					if ( $handler_query_tEdit->fetch() ) {
						$WordAction = "Edytuj";
						$WordAction2 = "znajdujące się w słowniku:";
						s{name="WordAction" value="WordAdd"}{name="WordAction" value="TransEdit"};
						s{name="WordName"}{name="WordName" value="$tEdit_word"}; #słowo
						s{name="WordId"}{name="WordId" value="$tEdit_id"}; #id słowa
						s{name="WordTransof"}{name="WordTransof" value="$tEdit_transof"}; #translacja
						s{name="WordLang2"}{name="WordLang2" value="tEdit_lang"};							
					} else {
						$errorCode .= "Błąd - brak wyników!\n";
					}
				} else {
					$errorCode .= "Błąd - nie udało się wykonać zapytania!\n";
				}
			} else {
				$errorCode .= "Błąd - nie wskazano słowa do edycji!\n";
			}		
		}		

		#TŁUMACZENIA
		


		s{<!-- errorCode -->}{<p>$errorCode</p>};
		s{<!-- LangAction -->}{$LangAction};
		s{<!-- WordAction -->}{$WordAction};
		s{<!-- WordAction2 -->}{$WordAction2};
		s{<!-- tableLanguagesList -->}{$tableLanguagesList};
		s{<!-- WordLangOptions -->}{$WordLangOptions};
		s{<!-- tableWordLists -->}{$tableWordLists};
		print;
	}	
close HTML;
$dbs->disconnect;