## crud_simple_create: This modules provide queries to create tables

query_create_get <- function(con, df, name, id_primary = NULL) {
	fields <- vapply(df, function(x) DBI::dbDataType(con, x), character(1))
	#names(fields) <- gsub("\\.", "_" ,names(fields)) # dots are not compatible with this syntax
	field_names <- dbQuoteIdentifier(con, names(fields))
	field_types <- unname(fields)
	fields <- paste0(field_names, " ", field_types)

	field_string <- paste(fields, collapse = ",\n  ")
	field_string
	create_query <- paste("CREATE TABLE IF NOT EXISTS ", name, " (\n",
											 "rownames integer primary key asc autoincrement,\n ",
											 field_string,
											 ");"
	)
	create_query
}
