--1.Вывести к каждому самолету класс обслуживания и количество мест этого класса:
SELECT aircrafts_data.model, seats.fare_conditions, count(seats.seat_no) AS seats_count
FROM aircrafts_data, seats
GROUP BY aircrafts_data.model, seats.fare_conditions
ORDER BY aircrafts_data.model;


--2. Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT aircrafts_data.model, count(seats.seat_no) AS seats_count
FROM aircrafts_data, seats
WHERE aircrafts_data.aircraft_code=seats.aircraft_code
GROUP BY aircrafts_data.model ORDER BY seats_count DESC
LIMIT 3;


--3.Найти все рейсы, которые задерживались более 2 часов
SELECT * FROM flights WHERE (actual_departure - scheduled_departure) > interval '2 hours';


--4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT ticket_flights.ticket_no, tickets.passenger_name, tickets.contact_data
FROM ticket_flights, tickets WHERE ticket_flights.fare_conditions = 'Business'
AND ticket_flights.ticket_no = tickets.ticket_no
ORDER BY tickets.book_ref DESC LIMIT 10;


--5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT *
FROM flights
LEFT JOIN ticket_flights
ON flights.flight_id = ticket_flights.flight_id AND ticket_flights.fare_conditions = 'Business'
WHERE ticket_flights.ticket_no IS NULL
ORDER BY flights.flight_id;


--6.Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT airports_data.airport_name, airports_data.city
FROM airports_data
JOIN flights
ON airports_data.airport_code = flights.departure_airport
WHERE (actual_departure - scheduled_departure) > interval '0 seconds'
ORDER BY airports_data.airport_name;


--7.Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT airports_data.airport_name, count(flights.flight_no) AS flights_count
FROM airports_data, flights
WHERE airports_data.airport_code = flights.departure_airport
GROUP BY airports_data.airport_name
ORDER BY flights_count DESC;


--8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT *
FROM flights
WHERE scheduled_arrival != actual_arrival;


--9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT aircrafts_data.aircraft_code, aircrafts_data.model, seats.seat_no
FROM aircrafts_data
JOIN seats USING (aircraft_code)
WHERE seats.fare_conditions != 'Economy'
AND aircrafts_data.model = 'Аэробус A321-200';


--10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airports_data.airport_code, airports_data.airport_name, airports_data.city
FROM airports_data
JOIN (SELECT city, COUNT(airport_code) AS airports_count
	   FROM airports_data
	   GROUP BY city) counts
ON airports_data.city = counts.city
WHERE counts.airports_count > 1;


--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT tickets.passenger_id, tickets.passenger_name, tickets.contact_data
FROM tickets
WHERE (SELECT SUM (ticket_flights.amount)
	   FROM ticket_flights
	   WHERE ticket_flights.ticket_no = tickets.ticket_no)
	   >
	   (SELECT AVG (ticket_flights.amount)
	   FROM ticket_flights);


--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flights.flight_id, flights.flight_no, flights.status
FROM flights
LEFT JOIN (SELECT airports_data.airport_code AS departure
		  FROM airports_data
		  WHERE airports_data.city::json ->> 'ru' = 'Екатеринбург') departure_code
ON flights.departure_airport = departure_code.departure
LEFT JOIN (SELECT airports_data.airport_code AS arrival
		  FROM airports_data
		  WHERE airports_data.city::json ->> 'ru' = 'Москва') arrival_code
ON flights.arrival_airport = arrival_code.arrival
WHERE flights.departure_airport = departure_code.departure
		AND flights.arrival_airport = arrival_code.arrival
		AND (flights.status = 'On Time' OR flights.status = 'Delayed');


--13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT * FROM ticket_flights
ORDER BY amount DESC
LIMIT 1)
UNION
(SELECT * FROM ticket_flights
ORDER BY amount
LIMIT 1);


--14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE IF NOT EXISTS bookings.customers
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    phone character varying NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT id UNIQUE (id),
    CONSTRAINT email UNIQUE (email),
    CONSTRAINT phone UNIQUE (phone)
);

ALTER TABLE bookings.customers
    OWNER to postgres;


--15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE IF NOT EXISTS bookings.orders
(
    or_id uuid NOT NULL DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL,
    quantity bigint NOT NULL,
    PRIMARY KEY (or_id),
    CONSTRAINT or_id UNIQUE (or_id),
    CONSTRAINT fk FOREIGN KEY (customer_id)
        REFERENCES bookings.customers (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE bookings.orders
    OWNER to postgres;


--16.Написать 5 insert в эти таблицы
--insert for customers
INSERT INTO customers(first_name,last_name,email,phone) VALUES ('Земфира','Рогова', 'two@email.by','+37545857622');
INSERT INTO customers(first_name,last_name,email,phone) VALUES ('Аза','Лапина', 'four@email.by','+37506774416');
INSERT INTO customers(first_name,last_name,email,phone) VALUES ('Ипполит','Авдеев', '886752254@email.by','+3750791654435');
INSERT INTO customers(first_name,last_name,email,phone) VALUES ('Петр','Иванов', '6687463844@email.by','+3754827541771');
INSERT INTO customers(first_name,last_name,email,phone) VALUES ('Корней','Аксёнов', 'ten@email.by','+375236138214');
--insert for orders
INSERT INTO orders(customer_id,quantity) VALUES ((SELECT id FROM customers WHERE email = 'two@email.by'), 74);
INSERT INTO orders(customer_id,quantity) VALUES ((SELECT id FROM customers WHERE email = '886752254@email.by'), 515);
INSERT INTO orders(customer_id,quantity) VALUES ((SELECT id FROM customers WHERE email = 'four@email.by'), 300);
INSERT INTO orders(customer_id,quantity) VALUES ((SELECT id FROM customers WHERE email = 'ten@email.by'), 1);
INSERT INTO orders(customer_id,quantity) VALUES ((SELECT id FROM customers WHERE email = 'four@email.by'), 22);


--17.Удалить таблицы
DROP TABLE customers, orders;