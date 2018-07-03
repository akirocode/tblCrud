library(DBI)
library(RSQLite)
library(tblCrud)

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
#names(iris1) <- gsub("\\.", "_" ,names(iris1)) # dots are not compatible with this syntax
## write it
dbWriteTable(con, "iris", iris1, row.names = "rownames")      # create and populate a table (adding the row names as a separate columns used as row ID)
data1 <- dbReadTable(con, "iris")
head(data1)

# update a table ----------------------------------------------------------

# create a modified version of `iris`
iris2 <- data1
iris2$Sepal.Length <- 5

## update using variables
crud_update(con, iris2, "iris")
data2 <- dbReadTable(con, "iris")
head(data2)

# bind new rows -----------------------------------------------------------

new_line<-
	tribble(
		~Sepal.Length, ~Sepal.Width, ~Petal.Length, ~Petal.Width, ~Species,
		50,           3.5,           14,          20, "new_species"
	)
require(dplyr)
new_df <-	bind_rows(new_line,	iris2)
head(new_df)
crud_sync(con, new_df, "iris")

data3 <- dbReadTable(con, "iris")
data3  ## <na>s remains because the table has been created with dbWriteTable
# todo: the id is not updated
unique(data3$Species)

#######
## create table with incremental id

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
new_line<-
	tribble(
		~Sepal.Length, ~Sepal.Width, ~Petal.Length, ~Petal.Width, ~Species,
		50,           3.5,           14,          20, "new_species"
	)
require(dplyr)
new_df <-	bind_rows(new_line,	iris3)
head(new_df)
crud_sync(con, new_df, tablename)

data3 <- dbReadTable(con, tablename) %>%
	tbl_df
data3  ## <na>s remains because the table has been created with dbWriteTable

######################
## autoincrement useful notes

## increment
incr_query <- "select AUTOINCREMENT from iris2;"
incr_query <- "SELECT SEQ from sqlite_sequence WHERE name='iris'"
incr_query <- "SELECT last_insert_rowid()"  ## this works
boh<-dbSendQuery(con, incr_query)
boh
dbFetch(boh)

