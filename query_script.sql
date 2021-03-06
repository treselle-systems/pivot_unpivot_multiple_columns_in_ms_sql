Single Column Pivot

/*---------------------------- Getting table data -------------------------------*/

WITH cte_result AS(
SELECT 
m.movieid ,m.title ,ROUND(r.rating,0) AS [rating], 
CAST(ROUND(r.rating,0) AS VARCHAR(5))+'_rating' AS [Star]
FROM [movielens].[dbo].[rating] r 
JOIN [movielens].[dbo].[movie] m ON m.movieid=r.movieid )

SELECT * FROM (
SELECT 
    movieid AS [MovieId],
    title AS [Movie Name],
    CAST(COUNT(*) AS FLOAT) AS [noofuser],
    CAST(SUM(Rating) AS FLOAT) AS [sumofrating],
    CAST(AVG(Rating) AS FLOAT) AS [avgofrating],
CASE WHEN star IS NULL THEN 't_rating' ELSE star END [RatingGrade]
FROM cte_result WHERE MovieId <= 2 GROUP BY ROLLUP(movieid,title,star) )ratingfilter
WHERE [Movie Name] IS NOT NULL ;


/* ----- Getting aggregated data using Pivot and converting rows to column ---- */

WITH cte_result AS(
SELECT 
    m.movieid ,m.title ,ROUND(r.rating,0) AS [rating], 
    CAST(ROUND(r.rating,0) AS VARCHAR(5))+'_rating' AS [Star]
FROM [movielens].[dbo].[rating] r 
JOIN [movielens].[dbo].[movie] m ON m.movieid=r.movieid )

SELECT 
[MovieId],
[Movie Name],
[1_rating],
[2_rating],
[3_rating],
[4_rating],
[5_rating],
[t_rating] FROM
(SELECT 
    movieid AS [MovieId] ,
    title AS [Movie Name],
    CAST(COUNT(*) AS FLOAT) AS [noofuser],
    CASE WHEN star IS NULL THEN 't_rating' ELSE star END [RatingGrade]
FROM cte_result GROUP BY ROLLUP(movieid,title,star))ratingfilter
PIVOT (SUM([noofuser]) FOR [RatingGrade] IN ([1_rating],[2_rating],[3_rating],[4_rating],[5_rating],[t_rating]))a 
WHERE [Movie Name] IS NOT NULL ORDER BY  movieid ;

###################################################################################################################

Unpivot and Pivot on Multiple Columns 

/*----------------------- Getting table data -------------------------------*/

WITH cte_result AS(
SELECT 
    m.movieid,
    m.title,
    ROUND(r.rating,0) AS rating,
    u.gender
FROM [movielens].[dbo].[rating] r 
JOIN [movielens].[dbo].[movie] m ON m.movieid=r.movieid
JOIN [movielens].[dbo].[user] u ON u.userid=r.userid
WHERE r.movieid < = 5 )

SELECT movieid,title,CAST(SUM(rating) AS FLOAT) AS rating,CAST(COUNT(*) AS FLOAT) AS nofuser,CAST(AVG(rating) AS FLOAT) avgr,gender FROM cte_result 
GROUP BY movieid,title,gender
ORDER BY movieid,title,gender

/* ----- Getting aggregated data using Unpivot and converting column to row ---- */
WITH cte_result AS(
SELECT 
    m.movieid,
    m.title,
    ROUND(r.rating,0) AS rating,
    u.gender
FROM [movielens].[dbo].[rating] r 
JOIN [movielens].[dbo].[movie] m ON m.movieid=r.movieid
JOIN [movielens].[dbo].[user] u ON u.userid=r.userid
WHERE r.movieid < = 5 )

SELECT movieid,title,gender+'_'+col AS col,value FROM (
SELECT movieid,title,CAST(SUM(rating) AS FLOAT) AS rating,CAST(COUNT(*) AS FLOAT) AS nofuser,CAST(AVG(rating) AS FLOAT) avgr,gender FROM cte_result GROUP BY movieid,title,gender) rt
unpivot ( value FOR col in (rating,nofuser,avgr))unpiv
ORDER BY movieid

/* ----- Getting aggregated data using Pivot and converting Multiple rows to Multiple column ---- */

WITH cte_result AS(
SELECT 
    m.movieid,
    m.title,
    ROUND(r.rating,0) AS rating,
    u.gender
FROM [movielens].[dbo].[rating] r 
JOIN [movielens].[dbo].[movie] m ON m.movieid=r.movieid
JOIN [movielens].[dbo].[user] u ON u.userid=r.userid
WHERE r.movieid < = 5 )

SELECT movieid,title,
[M_nofuser],[F_nofuser],
[M_rating],[F_rating],
[M_avgr],[F_avgr] 
FROM 
(
SELECT movieid,title,gender+'_'+col AS col,value FROM (
SELECT movieid,title,CAST(SUM(rating) AS FLOAT) AS rating,CAST(COUNT(*) AS FLOAT) AS nofuser,CAST(AVG(rating) AS FLOAT) avgr,gender FROM cte_result GROUP BY movieid,title,gender) rt
unpivot ( value FOR col in (rating,nofuser,avgr))unpiv )tp
pivot   ( SUM(value) FOR col in ([M_rating],[M_nofuser],[M_avgr],[F_rating],[F_nofuser],[F_avgr])) piv ORDER BY movieid


