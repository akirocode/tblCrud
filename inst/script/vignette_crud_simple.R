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

# update a table ----------------------------------------------------------

# create a modified version of `iris`
iris2 <- data1
iris2$Sepal_Length <- 5

## update using variables
crud_update(con, iris2, "iris")
data2 <- dbReadTable(con, "iris")
head(data2)

# bind new rows -----------------------------------------------------------

new_line<-
	tribble(
		~Sepal_Length, ~Sepal_Width, ~Petal_Length, ~Petal_Width, ~Species,
		50,           3.5,           14,          20, "new_species"
	)
require(dplyr)
new_df <-	bind_rows(new_line,	iris2)
head(new_df)
crud_sync(con, new_df, "iris")

data3 <- dbReadTable(con, "iris")
data3
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
## query get
fields <- vapply(df, function(x) DBI::dbDataType(con, x), character(1))
names(fields) <- gsub("\\.", "_" ,names(fields)) # dots are not compatible with this syntax
field_names <- dbQuoteIdentifier(con, names(fields))
field_types <- unname(fields)
fields <- paste0(field_names, " ", field_types)

field_string <- paste(fields, collapse = ",\n  ")
field_string
alter_query <- paste("CREATE TABLE IF NOT EXISTS ", tablename, " (\n",
                     "rownames integer primary key asc autoincrement,\n ",
										 field_string,
										 ");"
)
message(alter_query)
# query send
update <- dbSendQuery(con, alter_query)
dbReadTable(con, tablename)
df2 <- cbind(df, data.frame( rownames = as.character(NA)))
head(df2 %>% tbl_df)
head(new_df)
undebug(crud_sync)
names(df2) <- gsub("\\.", "_" ,names(df2)) # dots are not compatible with this syntax
crud_sync(con, df2, tablename)
dbReadTable(con, tablename)
dbDisconnect(con)
# alter_query <- "ALTER TABLE iris AUTO_INCREMENT = 1;"

######################
## wip
data3[order(data3$Sepal_Width),]

## rownames problem
mt2 <- bind_cols(mtcars, tibble(rownames(mtcars)))
bind_rows(mt2, data.frame(cyl = 8))
