####start of header####
---
title: "SQL querying using R"
author: "Elaine A."
date: "April 4, 2019"
email: "lelaine276@gmail.com"
source: "https://www.youtube.com/watch?v=s2oTUsAJfjI"
---
###End of header###
 
# load the sqldf package needed to run SQL queries in R   
library(sqldf)

# read the csv files containing the data into an R dataframe (i'll provide them as uploaded files)
employees = read.csv("C:/Users/Elaine/Downloads/r-sql-demo-files/employees.csv")

orders = read.csv("C:/Users/Elaine/Downloads/r-sql-demo-files/orders.csv")

# you can view them 
View(employees)
View(orders)

# getting the list of all male employees  in the company 
male_employees = sqldf("SELECT * 
                        FROM employees 
                        WHERE gender = 'm'
                       ")

# to get the total amount spent by employer with id = 1, in this case Matt. G
sum_of_id1 = sqldf("SELECT id, SUM(item_cost) 
                    FROM orders 
                    WHERE id = 1
                   ")
# to get all the types of rolls ordered for lunch
all_rolls = sqldf("SELECT * 
                   FROM orders 
                   WHERE item LIKE '%roll'
                  " )
# RIGHT JOIN SQL query is not supported in this package because it is assumed to be a repetition of the LEFT JOIN
# therefore LEFT JOIN used but you can alter the position of the tables, for instance, the orders table is put to the left while the employees is to the right
right_join = sqldf("SELECT * 
                    FROM orders a 
                    LEFT JOIN employees b 
                    ON a.id = b.id
                   ")
# but both LEFT and RIGHT JOIN dont create good looking tables, hence i'd advice INNER JOINING the tables
inner_join = sqldf("SELECT * 
                    FROM employees a, orders b 
                    WHERE a.id = b.id
                   ")
# if you want a list of all the cheap foods that cost less than 20 lessordered 
cheap_items = sqldf("SELECT *, 
                     (item_cost*quantity_ordered) as item_level_cost 
                     FROM orders a 
                     LEFT JOIN employees b ON a.id = b.id 
                     WHERE item_level_cost < 20 
                     ORDER BY item_level_cost
                    ")
# we can use a subquery to find employees that spend below average on lunch
# this piece below is our subquery. lets start by seeing what the average really is spent on lunch
average_lunchCost = sqldf("SELECT SUM(item_cost*quantity_ordered)/COUNT(DISTINCT id) AS avg_lunch_cost 
                           FROM orders 
                          WHERE id != 'NA'
                          ")
average_lunchCost
#avg_lunch_cost
#1             56
# hence the average spending on lunch is 56

# let us now find out who or which employees spend less than average on lunch
lower_than_averageLunch = sqldf("SELECT lastname, firstname, SUM(item_cost*quantity_ordered) AS lunchcost 
                                 FROM orders a 
                                 LEFT JOIN employees b ON a.id = b.id 
                                 WHERE a.id != 'NA' 
                                 GROUP BY a.id 
                                 HAVING lunchcost < (
                                                      SELECT SUM(item_cost*quantity_ordered)/COUNT(DISTINCT id) AS avg_lunch_cost 
                                                      FROM orders 
                                                      WHERE id != 'NA'
                                                    )
                                ")
