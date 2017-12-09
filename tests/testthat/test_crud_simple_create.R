library(DBI)
library(RSQLite)

context("query_create_get")

con <- dbConnect(drv=dbDriver("SQLite"), con =":memory:")

test_that("query_create_get create the iris query",{
	tablename <- "iris2"
	iris

	query <- query_create_get(con, iris, tablename)

	expected <- "CREATE TABLE IF NOT EXISTS  iris2  (
 rownames integer primary key asc autoincrement,
  `Sepal_Length` REAL,
  `Sepal_Width` REAL,
  `Petal_Length` REAL,
  `Petal_Width` REAL,
  `Species` TEXT );"
  expect_equal(query, expected)

})

dbDisconnect(con)
