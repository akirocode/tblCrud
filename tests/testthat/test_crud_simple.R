
library(tibble)

# query_update_get --------------------------------------------------------

context("query_update_get")

test_that("query_update_get works with one key and one value", {
	tbl <-
		tribble(
			~col1, ~col2,
			1,     2L
		)
	expect <- 'update iris set "col2"=$col2 WHERE "col1"=$col1'

	object <- query_update_get(tbl, "iris", "col1")

	expect_equal(object , expect)

})

test_that("query_update_get works with one key and multiple values", {
	tbl <-
		tribble(
			~col1, ~col2, ~col3, ~col4,
			1,     2L,     "3" ,   "4"
		)

	expect <- 'update iris set "col2"=$col2, "col3"=$col3, "col4"=$col4 WHERE "col1"=$col1'

	object <- query_update_get(tbl, "iris", "col1")

	expect_equal(object , expect)

})

test_that("query_update_get searching id into attrs", {
	tbl <-
		tribble(
			~col1, ~col2,
			1,     2L
		)
	attr(tbl, which = "id_primary") <- "col1"
	expect <- 'update iris set "col2"=$col2 WHERE "col1"=$col1'

	object <- query_update_get(tbl, "iris")

	expect_equal(object , expect)

})


# query_insert_get --------------------------------------------------------

context("query_insert_get")

test_that("query_insert_get works with one key and one value", {
	tbl <-
		tribble(
			~col1, ~col2,
			1,     2L
		)
	expect <- 'INSERT INTO iris (col2) VALUES ($col2)'

	object <- query_insert_get(tbl, "iris", "col1")

	expect_equal(object , expect)

})

test_that("query_insert_get works with different column and table names", {
	tbl <-
		tribble(
			~co1, ~co2,
			1,     2L
		)
	expect <- 'INSERT INTO mtcars (co2) VALUES ($co2)'

	object <- query_insert_get(tbl, "mtcars", "co1")

	expect_equal(object , expect)

})

test_that("query_insert_get works with one key and multiple values", {
	tbl <-
		tribble(
			~col1, ~col2, ~col3, ~col4,
			1,     2L,     "3" ,   "4"
		)

	expect <- 'INSERT INTO iris (col2, col3, col4) VALUES ($col2, $col3, $col4)'

	object <- query_insert_get(tbl, "iris", "col1")

	expect_equal(object , expect)

})

test_that("query_insert_get searching id into attrs", {
	tbl <-
		tribble(
			~col1, ~col2,
			1,     2L
		)
	attr(tbl, which = "id_primary") <- "col1"
	expect <- 'INSERT INTO iris (col2) VALUES ($col2)'

	object <- query_insert_get(tbl, "iris")

	expect_equal(object , expect)

})
