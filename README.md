
# Version

This is still an Alpha version.

# Typical usage

1. Create an empty table in the database with the schema of a data frame.
2. Append data to it.
3. Modify old data and append new data and sincronize the data on db.

For examples see the [Vignette](./vignettes/Introduction to tblCrud.Rmd)

# Compatibility

## Databases

At the moment it is tested only with SQLite, but the SQL code used should be enought generic to work also on MySQL.
