# This module is a "collection of functions" that build up query from the schema of a data.frame.
# See tests for examples.

# query_sync: update insert -----------------------------------------------

query_update_get <- function(df, name, id_primary = NULL) {
	if (is.null(id_primary)) {
		id_primary <- id_primary_get_from_attr(df)
	}
	key_ass <- query_part_assegnation_get(id_primary)
	value_list <- names(df)[names(df) != id_primary]   # remove the key field
	value_ass_list <- list()
	value_ass_list <- purrr::map(value_list, query_part_assegnation_get)
	value_ass_str <- paste(collapse = ", ", value_ass_list)
	paste0(
		'update ', name, ' set ', value_ass_str,' WHERE ', key_ass
	)
}

query_insert_get <- function(df, name, id_primary = NULL) {
	if (is.null(id_primary)) {
		id_primary <- id_primary_get_from_attr(df)
	}
	var_list = names(df)[names(df) != id_primary]
	column_list = paste0(collapse = ", ", var_list)
	value_list = paste0(collapse = ", ", "$", var_list)
	return(
		paste0("INSERT INTO ", name, " (", column_list, ") VALUES (", value_list, ")")
	)
}

# private -----------------------------------------------------------------

query_part_assegnation_get <- function(str) {
	paste0( "\"", str, "\"=$",	str )
}

id_primary_get_from_attr <- function(df) {
	if (! is.null(attr(df, "id_primary"))) {
		id_primary <- attr(df, "id_primary")
		return(id_primary)
	} else {
		stop("id_primary not given")
	}
}
