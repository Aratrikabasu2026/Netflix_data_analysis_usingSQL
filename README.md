<p align="center">
  <img src="netflix_logo.png"alt="Netflix Logo" width="160</p>

<h1 align="center">Netflix Data Analysis using SQL</h1>

<p align="center">
  Answering 15 real-world business questions about Netflix's content catalog with pure SQL.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-SQL-blue" alt="SQL"/>
  <img src="https://img.shields.io/badge/Database-PostgreSQL-336791" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Dataset-Netflix%20Titles-E50914" alt="Dataset"/>
  <img src="https://img.shields.io/badge/Queries-15-success" alt="15 Queries"/>
</p>

---

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Dataset](#dataset)
- [Database Schema](#database-schema)
- [Business Problems and Solutions](#business-problems-and-solutions)
- [SQL Concepts Demonstrated](#sql-concepts-demonstrated)
- [Key Findings](#key-findings)
- [Data Quality Notes and Limitations](#data-quality-notes-and-limitations)
- [How to Run](#how-to-run)
- [Repository Structure](#repository-structure)
- [Future Improvements](#future-improvements)
- [Author](#author)

---

## Project Overview

This project is an end-to-end SQL analysis of Netflix's movies and TV shows catalog. It starts with creating the table and then works through **15 business problems**, each solved with a focused SQL query. The goal is to turn raw catalog data into insights about content type, ratings, geography, genres, release trends, directors, and cast.

The project is designed to showcase practical SQL skills (aggregation, window functions, string and date manipulation, subqueries, CTEs, and array unnesting) that are directly applicable to data analyst and business analyst roles.

## Objectives

- Analyze the distribution of Movies vs TV Shows on the platform.
- Identify the most common content ratings for each content type.
- Find the countries, years, and genres that dominate the catalog.
- Surface the longest movies and long-running TV shows.
- Explore the work of specific directors and actors.
- Categorize content based on keywords found in its description.

## Dataset

The data is the public **Netflix Movies and TV Shows** dataset (commonly found on Kaggle), containing listings available on Netflix along with their metadata.

| Attribute | Details |
|---|---|
| Rows | One row per title (movie or TV show) |
| Source | Netflix Titles dataset (Kaggle) |
| Format | CSV imported into a SQL table |

## Database Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

| Column | Description |
|---|---|
| `show_id` | Unique ID of the title |
| `type` | `Movie` or `TV Show` |
| `title` | Name of the title |
| `director` | Director(s) of the title |
| `casts` | Comma-separated list of cast members |
| `country` | Country or countries of production |
| `date_added` | Date the title was added to Netflix (stored as text, e.g. `September 25, 2021`) |
| `release_year` | Original release year |
| `rating` | Content rating (e.g. TV-MA, PG-13) |
| `duration` | Minutes for movies, seasons for TV shows (e.g. `90 min`, `2 Seasons`) |
| `listed_in` | Genre categories |
| `description` | Short summary of the title |

## Business Problems and Solutions

| # | Business Problem | Techniques Used |
|---|---|---|
| 1 | Count the number of Movies vs TV Shows | `GROUP BY`, `COUNT` |
| 2 | Find the most common rating for Movies and TV Shows | CTE, `RANK() OVER (PARTITION BY ...)` |
| 3 | List all movies released in a specific year (e.g., 2020) | `WHERE`, `ORDER BY` |
| 4 | Find the top 5 countries with the most content | `GROUP BY`, `ORDER BY`, `LIMIT` |
| 5 | Identify the longest movie | `SPLIT_PART`, `CAST`, `ORDER BY` |
| 6 | Find content added in the last 5 years | `TO_DATE`, subquery, `INTERVAL` (plus a `LIKE` alternative) |
| 7 | Find all content by director 'Rajiv Chilaka' | Filtering |
| 8 | List all TV shows with more than 5 seasons | `SPLIT_PART`, `CAST` |
| 9 | Count the number of content items in each genre | `GROUP BY` on `listed_in` |
| 10 | Top 5 years with the highest content added in India | `RIGHT`, `LIKE`, `GROUP BY`, `LIMIT` |
| 11 | List all movies that are documentaries | `LIKE` pattern matching |
| 12 | Find all content without a director | `IS NULL` |
| 13 | Count movies featuring 'Salman Khan' in the last 10 years | `LIKE`, `EXTRACT(YEAR FROM CURRENT_DATE)` |
| 14 | Top 10 actors in Indian-produced movies | `UNNEST`, `STRING_TO_ARRAY`, `TRIM`, subquery |
| 15 | Label content as 'Good' or 'Bad' based on keywords in the description | `CASE WHEN`, `ILIKE` |

### Highlighted Queries

**Most common rating per content type (Problem 2)**

```sql
WITH rating_counts AS (
    SELECT
        type,
        rating,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    WHERE rating IS NOT NULL
    GROUP BY type, rating
)
SELECT type, rating, total
FROM rating_counts
WHERE rnk = 1;
```

**Top 10 actors in Indian movies (Problem 14)**

```sql
SELECT TRIM(actor) AS actor, COUNT(*) AS total_movies
FROM (
    SELECT UNNEST(STRING_TO_ARRAY("casts", ',')) AS actor
    FROM netflix
    WHERE type = 'Movie'
      AND country LIKE '%India%'
) AS actor_list
GROUP BY TRIM(actor)
ORDER BY total_movies DESC
LIMIT 10;
```

**Content categorization by keywords (Problem 15)**

```sql
SELECT category, COUNT(*) AS total_items
FROM (
    SELECT
        CASE
            WHEN description ILIKE '%kill%'
              OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS labelled
GROUP BY category;
```

The full set of queries is in [`mysqlproject_netflix_data_analysis.sql`](mysqlproject_netflix_data_analysis.sql).

## SQL Concepts Demonstrated

- **Aggregation:** `COUNT`, `GROUP BY`, `ORDER BY`, `LIMIT`
- **Window functions:** `RANK() OVER (PARTITION BY ...)`
- **CTEs and subqueries:** readable, multi-step logic
- **String functions:** `SPLIT_PART`, `RIGHT`, `TRIM`, `STRING_TO_ARRAY`, `LIKE`, `ILIKE`
- **Date functions:** `TO_DATE`, `INTERVAL`, `EXTRACT`, `CURRENT_DATE`
- **Array handling:** `UNNEST` to split multi-valued columns
- **Conditional logic:** `CASE WHEN`
- **Data cleaning:** `NULL` handling and type casting

## Key Findings

The queries are built to answer the following kinds of questions. Run them against your copy of the dataset to get exact figures:

- **Content mix:** Movies make up the larger share of the catalog compared to TV Shows.
- **Ratings:** Each content type has a dominant rating, found with a ranked CTE.
- **Geography:** A handful of countries, led by the United States and India, account for most of the content.
- **Release trends:** The Indian catalog can be broken down by the year titles were added to the platform.
- **Genres and talent:** Genre counts, director filmographies, and top actors in Indian movies are all easy to surface.
- **Sentiment-style tagging:** Keyword-based labeling gives a quick split of content into 'Good' and 'Bad' groups.

## Data Quality Notes and Limitations

- **Dialect:** Despite the file name, the queries use **PostgreSQL** functions (`SPLIT_PART`, `TO_DATE`, `UNNEST`, `ILIKE`, `STRING_TO_ARRAY`). To run them on MySQL, these would need to be rewritten (e.g. `SUBSTRING_INDEX`, `STR_TO_DATE`, `LIKE`, and a numbers table or `JSON_TABLE` instead of `UNNEST`).
- **Multi-valued columns:** `country` and `listed_in` store multiple comma-separated values in one cell, so Problems 4 and 9 count each unique combination as a group rather than each individual country or genre. Splitting them with `UNNEST(STRING_TO_ARRAY(...))`, as in Problem 14, would give true per-country and per-genre counts.
- **Problem 10 wording:** the query counts titles added per year in India; it does not compute an average.
- **Dates as text:** `date_added` is stored as `VARCHAR`, so date logic relies on parsing. Converting it to a `DATE` column during cleaning is recommended.
- **Keyword labeling:** Problem 15 is a simple keyword heuristic, not real sentiment analysis.

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```
2. **Download the dataset** (Netflix Titles CSV) and place it in the `data/` folder.
3. **Create the database and table** by running the `CREATE TABLE` block from the SQL file in PostgreSQL (psql, pgAdmin, DBeaver, etc.).
4. **Import the CSV**
   ```sql
   COPY netflix FROM '/path/to/netflix_titles.csv' DELIMITER ',' CSV HEADER;
   ```
5. **Run the queries** one by one and review the results.

## Repository Structure

```
.
├── images/
│   └── netflix-logo.png
├── data/
│   └── netflix_titles.csv
├── mysqlproject_netflix_data_analysis.sql
└── README.md
```


## Author
Aratrika Basu
**Your Name**

- GitHub:[@Aratrikabasu2026]_(https://github.com/Aratrikabasu2026)
- Email: basuaratrika7@gmail.com
If you found this project helpful, please give it a star.
