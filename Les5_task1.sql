 -- lesson5
 -- task 1.1
 -- Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
 -- Заполните их текущими датой и временем.

CREATE DATABASE DB_date;

USE DB_date;

CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	name CHAR(255),
	created_at TIMESTAMP,
	updated_at TIMESTAMP
	);
	
INSERT INTO users (name)
VALUES
('Jone'), ('Steave'), ('Jasika'), ('Kent'), ('Mariy');

SELECT * FROM users;

SHOW TABLES;
DESC users;

UPDATE users SET created_at = NOW();
UPDATE users SET updated_at = NOW();

-- lesson5
-- task 1.2
-- Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR 
-- и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

ALTER TABLE users MODIFY COLUMN created_at VARCHAR(100);
ALTER TABLE users MODIFY COLUMN updated_at VARCHAR(100);


UPDATE users SET created_at = ('20.10.2018 18:10') WHERE id = 1; 
UPDATE users SET created_at = ('20.11.2018 18:20') WHERE id = 2; 
UPDATE users SET created_at = ('25.01.2018 18:40') WHERE id > 2; 

UPDATE users SET updated_at = ('20.10.2019 8:10') WHERE id = 1; 
UPDATE users SET updated_at = ('20.11.2019 8:10') WHERE id = 2; 
UPDATE users SET updated_at = ('25.01.2019 8:10') WHERE id > 2; 


SELECT * FROM users;

UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i');
UPDATE users SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');


ALTER TABLE
  users
CHANGE
  created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE
  users
CHANGE
  updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE users;

-- lesson5
-- task 1.3
-- В таблице складских запасов storehouses_products в поле value 
-- могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, 
-- если на складе имеются запасы. Необходимо отсортировать записи таким образом,
-- чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы 
-- должны выводиться в конце, после всех записей.

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO
  storehouses_products (storehouse_id, product_id, value)
VALUES
  (1, 543, 0),
  (1, 789, 2500),
  (1, 3432, 0),
  (1, 826, 30),
  (1, 719, 500),
  (1, 638, 1);

SELECT
  *
FROM
  storehouses_products
ORDER BY
 value = 0, value ;
--  IF(value > 0, 0, 1),
--  value;


SELECT
  *
FROM
  storehouses_products
ORDER BY
  value = 0, value;
 
 
 -- Тема Операции, задание 4
-- (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в
-- августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')
SELECT * FROM users u ;
-- Добавления столбца в существующую таблицу  users
ALTER TABLE users ADD COLUMN birthday char(50);
-- Добавление дней рождения
INSERT INTO users (birthday) VALUES
	('1-june-1983'),
	('24-may-1992'),
	('09-noveber-1989'),
	('04-august-1980'),
	('15-may-1981');
-- Так как втавка произошла не так как мыслилось
SELECT * FROM users u WHERE IF (u.name = NULL, 1, 0);
DELETE FROM users u WHERE id > 5;
-- Изменнеие названия столбца
ALTER TABLE users RENAME COLUMN birthday TO birthday_at;
-- Вставка дней рождения как задумывалось, но по "топорному" наверное можно элегантнее
UPDATE users SET birthday_at =
	('1983-06-1') WHERE id = 1;
UPDATE users SET birthday_at =
	('1990-05-05') WHERE id = 2;
UPDATE users SET birthday_at =
	('1989-11-09') WHERE id = 3;
UPDATE users SET birthday_at =
	('1980-08-4') WHERE id = 4;
UPDATE users SET birthday_at =
	('1981-05-11') WHERE id = 5;
-- Перевод даты в формат 
ALTER TABLE users MODIFY COLUMN birthday_at TIMESTAMP; 
-- Выполненение запроса разобранного на вебинаре. Нового не добавить
SELECT name  
  FROM users
  WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

-- Тема Операции, задание 5
-- (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса.
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2);
-- Отсортируйте записи в порядке, заданном в списке IN.

DROP TABLE  IF EXISTS catalogs;
CREATE TABLE catalogs (
--  	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  	id INT,
 	name CHAR(100)
 	);
 
TRUNCATE catalogs ;
DESC catalogs ;

SELECT * FROM catalogs ;

INSERT INTO catalogs VALUES
  (2, 'Процессоры'),
  (4, 'Материнские платы'),
  (5, 'Видеокарты'),
  (1, 'Жесткие диски'),
  (3, 'Оперативная память');

 
SELECT
  *
FROM
  catalogs
WHERE
  id IN (5, 1, 2)
ORDER BY
  FIELD(id, 5, 1, 2);

-- Тема Агрегация, задание 1
-- Подсчитайте средний возраст пользователей в таблице users
SELECT
--   AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age
	ROUND(AVG(FLOOR(TO_DAYS(NOW())-TO_DAYS(birthday_at ))/365.25)) AS age -- чтобы хоть как-то отличалось
FROM
  users;
	  
-- Тема Агрегация, задание 2
-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT
  DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day,
  COUNT(*) AS total
FROM
  users
GROUP BY
  day
ORDER BY
  total DESC;

-- Тема Агрегация, задание 3
-- (по желанию) Подсчитайте произведение чисел в столбце таблицы
INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

SELECT ROUND(EXP(SUM(LN(id)))) FROM catalogs;

SHOW TABLES;
 
 
