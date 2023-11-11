.read data.sql


CREATE TABLE bluedog AS
  SELECT color, pet
  FROM students
  WHERE color = 'blue' AND pet = 'dog';

CREATE TABLE bluedog_songs AS
  SELECT color, pet, song
  FROM students
  WHERE color = 'blue' AND pet = 'dog';


CREATE TABLE smallest_int_having AS
  SELECT time, smallest
  FROM students
  GROUP BY smallest
  HAVING count(*) == 1;


CREATE TABLE matchmaker AS
  SELECT S1.pet, S2.song, S1.color, S2.color
  FROM students AS S1 
  JOIN students AS S2
  ON S1.time < S2. time AND S1.pet = S2.pet AND S1.song = S2.song;
  


CREATE TABLE sevens AS
  SELECT seven
  FROM (SELECT seven,time
		FROM students 
		WHERE number = 7) AS s
  JOIN (SELECT time
		FROM numbers
		WHERE numbers."7" = "True") AS n
  ON s.time = n.time;


CREATE TABLE average_prices AS
  SELECT category, AVG(MSRP) AS average_price
  FROM products
  GROUP BY category;


CREATE TABLE lowest_prices AS
  SELECT store, item, min(price) AS lowest_price
  FROM inventory
  GROUP BY item;


CREATE TABLE shopping_list AS
  SELECT name,store
  FROM products AS p
  JOIN lowest_prices AS l
  ON p.name = l.item
  GROUP BY category
  ORDER BY min(MSRP/rating);
  

CREATE TABLE total_bandwidth AS
  SELECT SUM(Mbs)
  FROM shopping_list AS l
  JOIN stores AS s
  ON l.store = s.store;

