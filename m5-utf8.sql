--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========

SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============
 

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа

select *, row_number() over (order by p.payment_date::date) "Cортировка платежей по дате"
from payment p

--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа

select *, row_number () over (partition by p.customer_id order by p.payment_date::date) "Cортировка платежей по дате"
from payment p

--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей

select *, sum(p.amount) over (partition by p.customer_id order by p.payment_date::date, p.amount ) "Нарастающая сумма платежей"
from payment p

--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.

select *, rank () over (partition by p.customer_id order by p.amount desc) "Ранжирование платежей по дате"
from payment p

--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select *, row_number() over (order by p.payment_date::date) "Cортировка платежей по дате" ,
row_number () over (partition by p.customer_id order by p.payment_date::date) "Cорт. покуп./платежей по дате",
sum(p.amount) over (partition by p.customer_id order by p.payment_date::date, p.amount ) "Нарастающая сумма платежей",
rank () over (partition by p.customer_id order by p.amount desc) "Ранжирование платежей по дате"
from payment p
 

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.

select p.customer_id, p.amount,  lead(amount,1, 0.0) over(partition by p.customer_id order by p.payment_date) "Предыдущий платеж"
from payment p 


--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select p.customer_id, lead(amount,1, 0.0) over(partition by p.customer_id order by p.payment_date) - p.amount "Разница платежей" 
from payment p 


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select *
from
(
select *, max(p.payment_date) over(partition by p.customer_id) as last_payment_date
from payment p 
) p2
where p2.payment_date = p2.last_payment_date


 --======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

select staff_id, date_of_payment, sum(day_amount) over (partition by staff_id order by date_of_payment)  sum_amount
from 
(
select p.staff_id, sum(p.amount) day_amount, p.payment_date::date date_of_payment
from payment p 
where   extract(year from p.payment_date) = 2005
		and
	 	extract(month  from p.payment_date) = 8
group by p.staff_id, date_of_payment
) p2


--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

select *
from
(
select p.payment_id,  p.customer_id , p.payment_date::date date_of_payment, 
 row_number() over (order by p.payment_date) as ranking
from payment p 
where   extract(year from p.payment_date) = 2005
		and
	 	extract(month  from p.payment_date) = 8
	 	and
	 	extract(day  from p.payment_date) = 20
) p2
where mod(p2.ranking, 100) = 0




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






