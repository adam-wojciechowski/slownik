use warnings;
use DBI; #aby łączyć siez bazą

require 'post.pl'; #obsługa POST-a

#wysyłanie nagłówka HTTP
print "Content-type: text/html \n\n";

#Konfiguracja połączenia z mysql-em
$db = "adamek_svr219";
$passwd = "3K4#L0f*vgY";

#połączenie do mysql'a i utworzenie przypisania
$dbs = DBI->connect("dbi:mysql:$db", $db, $passwd) || die "Nie mozna połączyć siez bazą: $DBI::errstr";

#przygotowanie zapytania:
$query = "SELECT * FROM words WHERE word=\"$FORM{'sWord'}\"";
$query_handle = $dbs->prepare($query);

#wykonanie zapytania:
$query_handle->execute();

#wyświetlenie wyników
$query_handle->bind_columns(\$id, \$word, \$lang, \$transof, \$desc);

print "<table>\n";
while ($query_handle->fetch()) {
	print "<tr>\n";
	print "<td>".$id."</td>\n";
	print "<td>".$word."</td>\n";
	print "<td>".$lang."</td>\n";
	print "<td>".$transof."</td>\n";
	print "<td>".$desc."</td>\n";
	print "</tr>\n";
}
print "</table>\n";

print "<form method=\"post\" action=\"baza_test2.pl\">\n
			<button type=\"submit\">Szukaj</button> słowa: 
			<input type=\"text\" placeholder=\"wpisz szukane słowo...\" name=\"sWord\" /> w słowniku.\n
		</form>\n
";

print "<h3>$FORM{'sWord'}</h3>";
