library(DBI)
library(RSQLite)
library(beeboler)

rm(list = ls())
wd <- "/tmp"
filename  <- "sq_test.sq"


# update a table ----------------------------------------------------------

## connect
con <- dbConnect(drv=dbDriver("SQLite"), con =":memory:", dbname=file.path(wd, filename))
## remove the old table
ret <- dbSendQuery(conn = con,
									 statement = paste0("DELETE FROM ", "iris"))
dbRemoveTable(con, "iris")
## setup the new table
iris1 <- iris
names(iris1) <- gsub("\\.", "_" ,names(iris1)) # dots are not compatible with this syntax
## write it
dbWriteTable(con, "iris", iris1, row.names = TRUE)      # create and populate a table (adding the row names as a separate columns used as row ID)
data1 <- dbReadTable(con, "iris")
head(data1)

# create a modified version of `iris`
iris2 <- iris1
iris2$Sepal_Length <- 5

iris2$row_names <- rownames(iris)  # use the row names as unique row ID
## update using variables
crud_update <- function(conn, df, name ) {
	update_query <- query_update_get(df = df, name = name, id_primary = "row_names")
	update <- dbSendQuery(con, update_query )
	dbBind(res = update, params = iris2)  # send the updated data
}
crud_update(con, iris1, "iris")
data2 <- dbReadTable(con, "iris")
head(data2)

# bind new rows -----------------------------------------------------------

new_line<-
	tribble(
		~Sepal_Length, ~Sepal_Width, ~Petal_Length, ~Petal_Width, ~Species,
		50,          13.5,           14,          20, "new_species"
	)
require(dplyr)
head(bind_rows(
	bind_cols(new_line, tibble(row_names = NA)),
	iris2))
######################
