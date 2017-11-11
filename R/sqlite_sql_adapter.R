id_primary =  "rownames"

crud_update <- function( conn, df, name ) {
	update_query <- query_update_get(df = df, name = name, id_primary = id_primary)
	update <- dbSendQuery(conn, update_query )
	dbBind(res = update, params = df)  # send the updated data
}

crud_insert <- function( conn, df, name ) {
	insert_query <- query_insert_get(df = df, name = name, id_primary = id_primary)
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
