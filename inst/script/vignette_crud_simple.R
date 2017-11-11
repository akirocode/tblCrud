library(DBI)
library(RSQLite)
library(beeboler)

rm(list = ls())
wd <- "/tmp"
filename  <- "sq_test.sq"


# setup_data --------------------------------------------------------------

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
dbWriteTable(con, "iris", iris1, row.names = "rownames")      # create and populate a table (adding the row names as a separate columns used as row ID)
data1 <- dbReadTable(con, "iris")
head(data1)

# create a modified version of `iris`
iris2 <- iris1
iris2$Sepal_Length <- 5

iris2$rownames <- rownames(iris)  # use the row names as unique row ID

# update a table ----------------------------------------------------------

## update using variables
crud_update(con, iris2, "iris")
data2 <- dbReadTable(con, "iris")
head(data2)

# bind new rows -----------------------------------------------------------

new_line<-
	tribble(
		~Sepal_Length, ~Sepal_Width, ~Petal_Length, ~Petal_Width, ~Species,
		50,          13.5,           14,          20, "new_species"
	)
require(dplyr)
new_df <-
	head(bind_rows(
		bind_cols(new_line, tibble(rownames = NA)),
		iris2))
new_df
crud_sync(con, new_df, "iris")

data3 <- dbReadTable(con, "iris")
unique(data3$Species)

######################
