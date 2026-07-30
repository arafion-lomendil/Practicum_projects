/* Проект первого модуля: анализ данных для агентства недвижимости
 * Часть 2. Решаем ad hoc задачи
 * 
 * Автор: Денис Рубцов
 * Дата:
*/



-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
categorized_data AS (
SELECT  id,
		first_day_exposition,
		days_exposition,
		last_price,
		total_area,
		rooms,
		balcony,
		floor,
		ceiling_height,
		is_apartment,
		open_plan,
		airports_nearest,
		parks_around3000,
		ponds_around3000,
        CASE 
        	WHEN city = 'Санкт-Петербург' THEN 'Санкт-Петербург'
        	WHEN type = 'город' AND city <> 'Санкт-Петербург' THEN 'ЛенОбл'
        END AS region,
        CASE
            WHEN days_exposition BETWEEN 1 AND 30 THEN '1-30 days'
            WHEN days_exposition BETWEEN 31 AND 90 THEN '31-90 days'
            WHEN days_exposition BETWEEN 91 AND 180 THEN '91-180 days'
            WHEN days_exposition >= 181 THEN '181 days +'
            WHEN days_exposition IS NULL THEN 'non category'
        END AS category
    FROM real_estate.advertisement
    LEFT JOIN real_estate.flats USING (id)
    LEFT JOIN real_estate.city USING (city_id)
    LEFT JOIN real_estate.type USING (type_id)
    WHERE
        first_day_exposition BETWEEN '2015-01-01' AND '2018-12-31'
        AND id IN (SELECT * FROM filtered_id)
    )
-- Продолжите запрос здесь
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных
SELECT region,
	   category,
	   COUNT(*) AS ad_count,
	   (SELECT COUNT(*) FROM real_estate.flats OVER(PARTITION BY category)) AS ad_share,
	   ROUND(AVG(last_price/total_area)::NUMERIC,2) AS price_per_meter,
	   ROUND(AVG(total_area)::NUMERIC,2) AS average_area,
	   ROUND(AVG(ceiling_height)::NUMERIC, 2) AS avg_ceil_height,
	   ROUND(AVG(airports_nearest)::NUMERIC, 2) AS avg_nearest_airport,
	   ROUND((SELECT COUNT(*) FROM categorized_data WHERE rooms = 0) / COUNT(*)::NUMERIC, 2) AS studio_perc,
	   ROUND((SELECT COUNT(*) FROM categorized_data WHERE is_apartment = 1) / COUNT(*)::NUMERIC, 2) AS apart_perc,
	   ROUND((SELECT COUNT(*) FROM categorized_data WHERE open_plan = 1) / COUNT(*)::NUMERIC, 2) AS open_plan_perc,
	   PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rooms) AS mediane_rooms,	   
	   PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY balcony) AS mediane_balcony,	   
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor) AS mediane_floor,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY parks_around3000) AS mediane_parks,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ponds_around3000) AS mediane_ponds
FROM categorized_data
LEFT JOIN real_estate.flats USING (id)
WHERE region IS NOT NULL
GROUP BY region, category
ORDER BY region DESC, category;

-- Продолжите запрос здесь
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных



-- Задача 2: Сезонность объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
    ),
-- Продолжите запрос здесь
-- Используйте id объявлений (СТЕ filtered_id), которые не содержат выбросы при анализе данных