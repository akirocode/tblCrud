id_primary =  "rownames"

# crud_create -------------------------------------------------------------

crud_create <- function( conn, df, name ) {
	.crud_create_empty(conn, df, name)
	df2 <- cbind(df, data.frame( rownames = as.character(NA)))
	crud_sync(conn, df2, name)
}

.crud_create_empty <- function( conn, df, name ) {
	create_query <- query_create_get(conn, df, name, id_primary)
	dbSendQuery(conn, create_query)
}

# crud_read ---------------------------------------------------------------

# crud_sync ---------------------------------------------------------------
# NB: the name sync is not good: from CRUD, update should be used.

crud_update <- function( conn, df, name ) {
	update_query <- query_update_get(df = df, name = name, id_primary = id_primary)
	update <- dbSendQuery(conn, update_query )
	colnames(df) <- dot2underscore(colnames(df))
	dbBind(res = update, params = df)  # send the updated data
}

crud_insert <- function( conn, df, name ) {
	insert_query <- query_insert_get(df = df, name = name, id_primary = id_primary)
	colnames(df) <- dot2underscore(colnames(df))
	update <- dbSendQuery(conn, insert_query )
	df <- df[ is.na(df[[id_primary]]), ] # save from bug, it should not necessary
	dbBind(res = update, params = df[,names(df) != id_primary])  # send the new data
}
crud_sync <- function( conn, df, name ) {
	df_insert <- df[ is.na(df[[id_primary]]), ]
	df_update <- df[ ! is.na(df[[id_primary]]), ]
	crud_insert( conn, df_insert, name )
	crud_update( conn, df_update, name )
}

# private -----------------------------------------------------------------

# tbl_to_tab <- function(df) {
# 	df[[id_primary]] <- rownames(df)  # use the row names as unique row ID
# 	df
# }
#
# tab_to_tbl <- function(df) {
# 	rownames(df) <- df[[id_primary]]
# 	df[[id_primary]] <- NULL
# 	df
# }
