
library(DBI)
library(RSQLite)
library(tblCrud)
require(dplyr)

rm(list = ls())
wd <- "/tmp"
filename  <- "sq_test.sq"
tablename <- "iris"

# crud_create -------------------------------------------------------------

## connect

con <- dbConnect(drv=dbDriver("SQLite"), dbname=file.path(wd, filename))

## remove the old table
tablename <- "iris2"
dbRemoveTable(con, tablename)
## setup the new table
iris2 <- iris
df <- iris2
## create
# names(df) <- gsub("\\.", "_" ,names(df)) # dots are not compatible with this syntax
update <- crud_create(con, df, tablename)

iris3 <- dbReadTable(con, tablename)

new_entity <-
	tibble(
		Sepal.Length = 50,
		Sepal.Width  = 3.5,
		Petal.Length = 14,
		Petal.Width  = 20,
		Species      = "new_species"
	)
new_entity
new_df <-	bind_rows(new_entity,	iris3)

write_entities <- function(con, tablename, df) {
	if (is.null(df$rownames)) df$rownames <- NA_integer_
	local_table <- crud_sync(con, df, tablename)
	local_table
}

local_table <- write_entities(con, tablename, df = new_df)

tail(local_table)
data3 <- dbReadTable(con, tablename) %>%
	tbl_df
tail(data3)
