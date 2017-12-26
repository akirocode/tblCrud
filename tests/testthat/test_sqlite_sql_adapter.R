require(DBI)
require(RSQLite)
# require(testthat)

context("integration test update table")

# init --------------------------------------------------------------------

t_label = "sqlite_sql_adapter"

## see vignette_crud_simple

# setup test_db ---------------------------------------------------------
mk_test_db <- function() {
	t_db <- list()
	t_db$filename <- tempfile(t_label, fileext = ".sqlite")
	t_db$tab_name <- paste0("tab_", t_label)
	t_db$con <- dbConnect(drv=dbDriver("SQLite"), con =":memory:", dbname=file.path(t_db$filename))
# dbRemoveTable(con, tab_name)
	t_db
}
rm_test_db <- function(t_db) {
	dbDisconnect(t_db$con)
	file.remove(t_db$filename)
}

# setup test_data ------------------------------------------------------
mk_td <- function(t_db) {
	td <- list()
	td$tbl_simple <- tibble::tibble(colA = c(1, 2),
																	colB = c(1, 10))
	td$tbl_simple[[id_primary]] <- rownames(td$tbl_simple)  # use the row names as unique row ID
	dbWriteTable(t_db$con, t_db$tab_name, td$tbl_simple)
	td
}

# tests -------------------------------------------------------------------

test_that("Table update returns error if there is no id_primary", {
	t_db <- mk_test_db()
	td <- mk_td(t_db)

	tbl_modified <- within(td$tbl_simple, {
		colB[1] <- 3
	})
	tbl_modified[[id_primary]] <- NULL

	expect_error(
		crud_update(con, tbl_modified, t_db$tab_name)
	)
	rm_test_db(t_db)
})

test_that("Simple table update", {
	t_db <- mk_test_db()
	td <- mk_td(t_db)

	tbl_modified <- within(td$tbl_simple, {
		colB[1] <- 3
	})

	crud_update(t_db$con, tbl_modified, t_db$tab_name)

	data_reread <- dbReadTable(t_db$con, t_db$tab_name)
	expect_equal(as.data.frame(data_reread)
							 , as.data.frame(tbl_modified)) # fix

	rm_test_db(t_db)
})

test_that("Simple table add new line", {
	t_db <- mk_test_db()
	td <- mk_td(t_db)
	line_new <- data.frame(
		colA     = 4,
		colB     = 5,
		rownames = NA
	)
	tbl_modified <- rbind(td$tbl_simple, line_new)

	crud_insert(t_db$con, tbl_modified, t_db$tab_name)

	data_reread <- dbReadTable(t_db$con, t_db$tab_name)
	expect_equal(as.data.frame(data_reread)
							 , as.data.frame(tbl_modified)) # fix

	rm_test_db(t_db)
})

test_that("crud_insert work", {
	t_db <- mk_test_db()
	td <- mk_td(t_db)
	line_new <- data.frame(
		colA     = 4,
		colB     = 5,
		rownames = NA
	)
	tbl_modified <- rbind(td$tbl_simple, line_new)

	crud_insert(t_db$con, tbl_modified, t_db$tab_name)

	data_reread <- dbReadTable(t_db$con, t_db$tab_name)
	expect_equal(as.data.frame(data_reread)
							 , as.data.frame(tbl_modified)) # fix

	rm_test_db(t_db)
})

test_that("Simple table sync", {
	t_db <- mk_test_db()
	td <- mk_td(t_db)
	line_new <- data.frame(
		colA     = 4,
		colB     = 5,
		rownames = NA
	)
	tbl_modified_1 <- rbind(td$tbl_simple, line_new)
	tbl_modified <- within(tbl_modified_1, {
		colB[1] <- 3
	})

	crud_sync(t_db$con, tbl_modified, t_db$tab_name)

	data_reread <- dbReadTable(t_db$con, t_db$tab_name)
	expect_equal(as.data.frame(data_reread)
							 , as.data.frame(tbl_modified)) # fix

	rm_test_db(t_db)
})
## work in progress

## test crud_update function(?)

context("test crud_create")

test_that("crud_create works with '.' in colnames", {
	## 0. setup
	t_db <- mk_test_db()
	td <- mk_td(t_db)
	## 1. init
	df <- iris
	df$Species <- as.character(df$Species) #avoid factor warnings
	tablename <- "iris"
  ## 2. do
	crud_create(t_db$con, df, tablename)
  ## 3. check
	iris_read <- dbReadTable(t_db$con, tablename)
	expect_equal(1:150, iris_read$rownames)
  ## 4.
	rm_test_db(t_db)
})





