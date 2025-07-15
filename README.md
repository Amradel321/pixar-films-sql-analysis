# Pixar Films Analysis

## Overview

This project explores a structured SQL-based analysis of Pixar Animation Studios' films using a normalized dataset with tables containing financial, critical, genre, crew, and award data. The dataset was provided in Excel format and imported into MySQL for querying.

The SQL queries are grouped by analytical task. Each section includes the query followed by an explanation of how it was designed and how it satisfies the task requirements. The queries are written to be both efficient and readable, using SQL best practices such as CTEs, conditional expressions, aggregate functions, and joins.

---

## Task 1: Financial Performance

```sql
SELECT f.film, YEAR(release_date) AS release_year,
       ROUND(budget / 1000000, 1) AS budget_milions,
       ROUND(box_office_worldwide / 1000000, 1) AS Worldwide_gross_millions,
       ROUND(((box_office_worldwide - budget) / budget) * 100, 1) AS ROI_Percentage
FROM pixar_films f
JOIN box_office o ON f.film = o.film
WHERE budget IS NOT NULL AND budget > 0
ORDER BY ROI_Percentage DESC;
```

**Explanation:**

* This query joins `pixar_films` with `box_office` using the common `film` field.
* It extracts the release year, calculates budget and worldwide gross in millions, and computes the ROI as a percentage.
* It filters out films with missing or zero budgets as instructed.
* The results are sorted by ROI to highlight the most financially successful films.

---

## Task 2: Award Analysis

```sql
WITH awards AS (
  SELECT film,
         SUM(CASE WHEN status LIKE 'won%' THEN 1 ELSE 0 END) AS awards_won,
         COUNT(*) AS total_nominations
  FROM academy
  WHERE status LIKE 'won%' OR status LIKE 'nominated%'
  GROUP BY film
)
SELECT film, awards_won, total_nominations,
       ROUND((awards_won / total_nominations) * 100, 1) AS win_percentage
FROM awards
HAVING awards_won > 0
ORDER BY win_percentage DESC;
```

**Explanation:**

* A Common Table Expression (CTE) is used to first calculate wins and total nominations.
* Win percentage is then calculated in the main query.
* The `HAVING` clause filters films to include only those with at least one win.
* This approach separates logic into readable steps and ensures accurate percentages.

---

## Task 3: Genre Profitability

```sql
SELECT value AS subgenre,
       ROUND(AVG(box_office_worldwide) / 1000000, 1) AS avg_worldwide_gross_millions,
       COUNT(DISTINCT g.film) AS num_of_films
FROM genres g
JOIN box_office o ON g.film = o.film
GROUP BY subgenre
HAVING num_of_films > 2
ORDER BY avg_worldwide_gross_millions DESC
LIMIT 5;
```

**Explanation:**

* This query calculates profitability by subgenre.
* `COUNT(DISTINCT g.film)` ensures that film duplications in genres are handled.
* A `HAVING` clause is used to filter subgenres with fewer than 3 films.
* It orders by gross to find the top 5 profitable subgenres.

---

## Task 4: Director Impact Study

```sql
SELECT name,
       ROUND(AVG(rotten_tomatoes_score), 1) AS avg_rotten_tomatoes_score,
       ROUND(AVG(box_office_worldwide) / 1000000, 1) AS avg_worldwide_gross_millions,
       ROUND(AVG(imdb_score), 1) AS avg_imdb_score,
       COUNT(DISTINCT p.film) AS num_of_films
FROM pixar_people p
JOIN public_response r ON p.film = r.film
JOIN box_office o ON p.film = o.film
WHERE role_type = 'director'
GROUP BY name
HAVING num_of_films > 1
ORDER BY avg_worldwide_gross_millions DESC;
```

**Explanation:**

* This query assesses directors' impacts using three key metrics.
* Filters by directors only and ensures each director directed more than one film.
* Joins across three tables to fetch the necessary performance data.
* Uses aggregation functions to compute average scores and gross.

---

## Task 5: Franchise Comparison

```sql
SELECT
  CASE
    WHEN f.film LIKE 'Toy Story%' THEN 'Toy Story'
    WHEN f.film LIKE 'Cars%' THEN 'Cars'
    WHEN f.film LIKE 'Finding%' THEN 'Finding Nemo/Dory'
  END AS franchise,
  COUNT(f.film) AS num_of_films,
  ROUND(SUM(box_office_worldwide) / 1000000, 1) AS worldwide_gross_millions,
  ROUND(AVG(f.run_time), 1) AS avg_run_time
FROM pixar_films f
JOIN box_office o ON f.film = o.film
WHERE f.film LIKE 'Toy Story%' OR f.film LIKE 'Cars%' OR f.film LIKE 'Finding%'
GROUP BY franchise
ORDER BY worldwide_gross_millions DESC;
```

**Explanation:**

* Uses a `CASE` statement to group films under franchise labels.
* Aggregates gross and runtime data for each group.
* Counts how many films belong to each franchise.
* Designed for readability and maintains logic separation.

---

## Task 6: Budget Category Analysis

```sql
SELECT
  CASE
    WHEN budget < 100000000 THEN 'Low budget'
    WHEN budget BETWEEN 100000000 AND 150000000 THEN 'Medium budget'
    WHEN budget > 150000000 THEN 'High budget'
  END AS budget_category,
  ROUND(AVG(metacritic_score), 1) AS avg_metacritic_score,
  ROUND(AVG(box_office_worldwide) / 1000000, 1) AS avg_worldwide_gross_millions,
  COUNT(o.film) AS number_of_films
FROM box_office o
JOIN public_response r ON o.film = r.film
GROUP BY budget_category;
```

**Explanation:**

* Categorizes budgets using a `CASE` expression.
* Aggregates Metacritic scores, box office data, and film counts.
* Avoids listing individual films because the focus is on budget groups.

---

## Conclusion

This project demonstrates a solid command of SQL analytical techniques including:

* Filtering using `WHERE` and `HAVING`
* Aggregations with `AVG`, `SUM`, `COUNT`
* Formatting using `ROUND`
* Conditional logic via `CASE`
* Clean and efficient joins
* Readable and maintainable query structure

The final dataset enables deep insights into Pixar’s creative and financial output, from director effectiveness to genre profitability and franchise success.
