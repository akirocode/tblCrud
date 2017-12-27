# Purposes and design

## Precondition on tables

Tables we use will be characterise by one column which will be the *primary_id* or the *rowname* of the column. The type of this variable is `string`, `factor` or `integer`.

The second kind of id is the incremental integer number of the database: the *incremental_id*. This is necessary only in case more than one user access to the database and if the user wants to change a primary_id without lose the connection with the database.

NB: the two id can be the same. At the moment they are confused in the code.

# Usage

## Typical usage

1. Create an empty table in the database with the schema of a data frame.
2. Append data to it.
3. Modify old data and append new data and sincronize the data on db.

```{r, echo=FALSE, include=FALSE}
library(DBI)
library(dplyr, warn.conflicts = F)
library(RSQLite)
library(tblCrud)
```

```{r}
con <- dbConnect(drv=dbDriver("SQLite"), con =":memory:")

tablename <- "sql_iris"
bool_return <- crud_create(con, iris, tablename)
```

This is the content of the table:

	```{r}
dbReadTable(con, tablename) %>%
	tail
```

Grab a small subset, which work on:

	```{r}
df <- dbGetQuery(con, paste("select * from", tablename, " where Species == 'setosa' limit 10"  ))
df
```

Modify this subset:

	```{r}
df_1 <- df %>% mutate(Petal.Width = 50)
```

Add new lines to this subset:

	```{r}
new_line<-
	tribble(
		~Sepal.Length, ~Sepal.Width, ~Petal.Length, ~Petal.Width, ~Species,
		10,           3.5,           14,          20, "new_species"
	)
new_df <-	bind_rows(new_line,	df_1)
head(new_df)
```

Now synchronize this subset on database:

	```{r}
crud_sync(con, new_df, tablename)

dbReadTable(con, tablename) %>%
	tail
```

# Compatibility

## Databases

At the moment it is tested only with SQLite, but the SQL code used should be enought generic to work also on MySQL.
