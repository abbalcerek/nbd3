
//////////// Część 1 – Filmy

// 1. Zaimportuj dane uruchamiając zapytania zgodnie z instrukcjami wyświetlanymi po wpisaniu polecenia 
// :play movie-graph. Przeanalizuj i uruchom przykładowe zapytania. Następnie napisz następujące zapytania: 

// nie zalaczam zapytania importujacego baze poniewaz jest ogromne

// 2. Wszystkie filmy, w których grał Hugo Weaving
match (:Person{name: "Hugo Weaving"}) -[:ACTED_IN]-> (m: Movie) return m;

// 3. Reżyserzy filmów, w których grał Hugo Weaving 
match (:Person{name: "Hugo Weaving"}) -[:ACTED_IN]-> (m: Movie) <-[:DIRECTED]- (r: Person) return r;

// 4. Wszystkie osoby, z którymi Hugo Weaving grał w tych samych filmach 
match (:Person{name: "Hugo Weaving"}) -[:ACTED_IN]-> (m: Movie) <-[:ACTED_IN]- (actor: Person) return actor;

// 5. Listę aktorów (aktor = osoba, która grała przynajmniej w jednym filmie) wraz z ilością filmów, w których grali 
match (:Person{name: "Hugo Weaving"}) -[:ACTED_IN]-> (m: Movie)
match (actor: Person) -[:ACTED_IN]-> (m: Movie)
return actor, count(*);
    
// 6. Listę filmów, w których grał zarówno Hugo Weaving jak i Keanu Reeves 
match (:Person{name: "Hugo Weaving"}) -[:ACTED_IN]-> (m: Movie) 
match (:Person{name: "Keanu Reeves"}) -[:ACTED_IN]-> (m: Movie)
return m;

// 7. Zestaw zapytań powodujących uzupełnienie bazy danych o film Captain America: The First Avenger wraz z 
// uzupełnieniem informacji o reżyserze, scenarzystach i odtwórcach głównych ról (w oparciu o skrócone 
// informacje z IMDB - http://www.imdb.com/title/tt0458339/) + zapytanie pokazujące dodany do bazy film wraz 
// odtwórcami głównych ról, scenarzystą i reżyserem. Plik SVG ma pokazywać wynik ostatniego zapytania.  
// Uwaga: W wypadku zadania 7 dopuszczalne jest wykorzystanie większej niż 1 ilości zapytań 

// create movie
CREATE (captainAmerica :Movie {title:'Captain America: The First Avenge', released:2011, tagline:'When patriots become heroes'})

// create actors with relations
MERGE (hugo: Person{name: "Hugo Weaving", born: 1960})
CREATE (hugo) -[:ACTED_IN]-> (captainAmerica)

MERGE (hayley: Person{name: "Hayley Atwell", born: 1982})
CREATE (hayley) -[:ACTED_IN]-> (captainAmerica)

MERGE (sebastian: Person{name: "Sebastian Stan", born: 1982})
CREATE (sebastian) -[:ACTED_IN]-> (captainAmerica)

MERGE (tommy: Person{name: "Tommy Lee Jones", born: 1946})
CREATE (tommy) -[:ACTED_IN]-> (captainAmerica)

MERGE (chris: Person{name: "Chris Evans", born: 1981})
CREATE (chris) -[:ACTED_IN]-> (captainAmerica)

// create director with relations
MERGE (joe: Person{name: "Joe Johnston", born: 1950})
CREATE (joe) -[:DIRECTED]-> (captainAmerica)

// create screen writer with relations
MERGE (christopher: Person{name: "Christopher Markus", born: 1970})
CREATE (christopher) -[:WROTE]-> (captainAmerica)

return captainAmerica, hugo, hayley, sebastian, tommy, chris, joe, christopher;


//////////////  Część 2 – Wycieczki górskie 

// 1. Zaimportuj dane uruchamiając skrypt task2.cypher. Napisz następujące zapytania: 

// clears data before import
MATCH (n) DETACH DELETE n;
// to run script from cypher-shell semicolon at the end is needed or from bash cypher-shell --file task2.cypher
:source task2.cypher

// 2. Znajdź wszystkie trasy którymi można dostać się z Darjeeling na Sandakphu 
match path = ({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"})
return path;

// 3. Znajdź trasy którymi można dostać się z Darjeeling na Sandakphu, mające najmniejszą ilość etapów 
match path = allShortestPaths(({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"})) 
return path;

// as shortest path returns single path
match path = shortestPath(({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"})) 
    with length(path) as l
        match p = ({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"})
        where l = length(p)
        return p

// 4. Znajdź mające najmniej etapów trasy którymi można dostać się z Darjeeling na Sandakphu i które mogą być wykorzystywane zimą 
match path = allShortestPaths(({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"})) 
  where all (r in relationships(path) where r.winter = "true")  
  return path;

// 5. Uszereguj trasy którymi można dostać się z Darjeeling na Sandakphu według dystansu 
match path = ({name: "Darjeeling"}) -[*]-> ({name: "Sandakphu"}) 
return path, length(path) order by length(path);

// 6. Znajdź wszystkie trasy dostępne latem, którymi można poruszać się przy pomocy roweru (twowheeler) z Darjeeling 

// zamieszczam pusty json jako, ze nie da sie wyeksportowac jsona dla pustego grafu
match path = ({name: "Darjeeling"}) -[r:twowheeler*]-> () 
  where all (r in relationships(path) where r.summer = "true")  
  return path;

// 7. Znajdź wszystkie miejsca do których można dotrzeć przy pomocy roweru (twowheeler) z Darjeeling latem 
match path = ({name: "Darjeeling"}) -[r:twowheeler*]-> (dest) 
  where all (r in relationships(path) where r.summer = "true")  
  return distinct(dest);


// Część 3 – Połączenia lotnicze 
// 1.	Zaimportuj dane uruchamiając skrypt task3.cypher. Napisz następujące zapytania: 

// clears data before import
MATCH (n) DETACH DELETE n;
// to run script from cypher-shell semicolon at the end is needed
:source task3.cypher

// 2.	Uszereguj porty lotnicze według ilości rozpoczynających się w nich lotów
match (:Flight)-[:ORIGIN]->(a:Airport) 
return a, count(*) as c order by c desc;

// 3.	Znajdź wszystkie porty lotnicze, do których da się dolecieć (bezpośrednio lub z przesiadkami) z Los Angeles (LAX) wydając mniej niż 3000  

// pomocnicze krawedzie do za zadan 3, 4, 5

// tworzy jedna krawedz per lot z najmniejsza cena biletu
// !!! zakladay dalej ze polaczenie roozumiemy jako ciag lotow a nie biletow.
// (jesli chcemy wyznaczyc trasy na podstawie ticketow nie lotow to trzeba dodac krawedzie z prostrzego zapytania ponizej)
match (x)<-[:ORIGIN]-(f)-[:DESTINATION]->(y:Airport)
match (f) <-- (t:Ticket) 
with x, y, max(t.price) as lowestPrice, id(f) as flightId
merge (x)-[:FLIGHT{price:lowestPrice, flight_id: flightId}]->(y);

// tworzy 3 krawedzie dla kazdego lotu. jedna dla kazdej klasy bilet
match (x)<-[:ORIGIN]-(f)-[:DESTINATION]->(y:Airport)
match (f) <-- (t:Ticket) 
merge (x)-[fl:FLIGHT{price:t.price, flight_id: id(f)}]->(y);

MATCH p=(la: Airport{name:"LAX"})-[:FLIGHT*..4]->(x: Airport)
WITH reduce(total=0, f in relationships(p) | total +f.price) as total_price, p 
where total_price <= 3000
RETURN distinct(last(nodes(p)));

// 4.	Uszereguj połączenia, którymi można dotrzeć z Los Angeles (LAX) do Dayton (DAY) według ceny biletów

// pusty wynik dolaczam pusty json
MATCH p=(la: Airport{name:"LAX"})-[:FLIGHT*..4]->(x: Airport{name: "DAY"})
WITH reduce(total=0, f in relationships(p) | total +f.price) as total_price, p 
RETURN p order by total_price;

// 5.	Znajdź najtańsze połączenie z Los Angeles (LAX) do Dayton (DAY)

// pusty wynik dolaczam pusty json
MATCH p=(la: Airport{name:"LAX"})-[:FLIGHT*..4]->(x: Airport{name: "DAY"})
WITH reduce(total=0, f in relationships(p) | total +f.price) as total_price, p 
RETURN p order by total_price limit 1;

// 6.	Znajdź najtańsze połączenie z Los Angeles (LAX) do Dayton (DAY) w klasie biznes 

// pomocnicze krawedzie do za zadan 6 
match (la)<-[:ORIGIN]-(f)-[:DESTINATION]->(x:Airport)
match (f) <-- (t:Ticket{class:"business"}) 
merge (la)-[fl:BUSINESS_FLIGHT{price:t.price, flight_id: id(f)}]->(x);

// pusty wynik dolaczam pusty json
MATCH p=(la: Airport{name:"LAX"})-[r:BUSINESS_FLIGHT*..4]->(x: Airport{name: "DAY"})
WITH reduce(total=0, f in relationships(p) | total +f.price) as total_price, p 
RETURN p order by total_price limit 1;

// 7.	Uszereguj linie lotnicze według ilości miast, pomiędzy którymi oferują połączenia 
// (unikalnych miast biorących udział w relacjach :ORIGIN i :DESTINATION węzłów typu Flight obsługiwanych przez daną linię) 

MATCH (f:Flight)-[:DESTINATION|ORIGIN]->(a:Airport)
RETURN f.airline, count(distinct(a)) order by count(distinct(a)) desc;

// 8.	Znajdź najtańszą trasę łączącą 3 różne porty lotnicze 
MATCH p=(la: Airport)-[:FLIGHT*..4]->(x: Airport)
WITH size(reduce(dist=[], n in nodes(p) | case when not n in dist then dist + n end)) as count, p
where count = 3
WITH reduce(total=0, f in relationships(p) | total +f.price) as total_price, p
RETURN p, min(total_price) order by min(total_price) limit 1;


// Uwaga w tych zadaniach wskazane jest wykorzystanie możliwości stworzenia dodatkowych relacji pomiędzy miastami. 
// Można stworzyć relację i wykonywać ewentualne operacje pomocnicze przy pomocy dodatkowych zapytań, 
// wynikowe SVG/JSON mają dotyczyć zapytania głównego (zwracającego wynik wskazany w zadaniu).  
// We wszystkich zadaniach z tej części można ograniczyć się do 2 przesiadek.
