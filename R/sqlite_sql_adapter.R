id_primary =  "rownames"

# crud_create -------------------------------------------------------------

crud_create <- function( conn, df, name ) {
	.crud_create_empty(conn, df, name)
	df2 <- cbind(df, data.frame( rownames = as.integer(NA), stringsAsFactors = FALSE))
	crud_sync_aincr(conn, df2, name)
}

.crud_create_empty <- function( conn, df, name ) {
	create_query <- query_create_get(conn, df, name, id_primary)
	res <- dbSendQuery(conn, create_query)
	dbClearResult(res)
}

# crud_read ---------------------------------------------------------------

# crud_sync ---------------------------------------------------------------
# NB: the name sync is not good: from CRUD, update should be used.

crud_update <- function( conn, df, name ) {
	update_query <- query_update_get(df = df, name = name, id_primary = id_primary)
	update <- dbSendQuery(conn, update_query )
	colnames(df) <- dot2underscore(colnames(df))
	res <- dbBind(res = update, params = df)  # send the updated data
	dbClearResult(res)
}

crud_insert_asis <- function( conn, df, name ) {
	insert_query <- query_insert_get(df = df, name = name, id_primary = id_primary)
	colnames(df) <- dot2underscore(colnames(df))
	update <- dbSendQuery(conn, insert_query )
	df <- df[ is.na(df[[id_primary]]), ] # save from bug, it should not necessary
	res <- dbBind(res = update, params = df[,names(df) != id_primary])  # send the new data
	dbClearResult(res)
}

crud_insert_aincr <- function( conn, df, name ) {
	dbBegin(conn)     # it does not seem necessary
	crud_insert_asis(conn, df, name)
	rowids <- get_rowid_sequence(conn = conn, length_out = nrow(df))
	dbCommit(conn)
	df_new <- df
	df_new$rownames <- rowids
	df_new
}

crud_sync_asis <- function( conn, df, name ) {
	df_insert <- df[ is.na(df[[id_primary]]), ]
	df_update <- df[ ! is.na(df[[id_primary]]), ]
	crud_insert_asis( conn, df_insert, name )
	crud_update( conn, df_update, name ) # assume nothing is changed
}

crud_sync_aincr <- function( conn, df, name ) {
	df_insert <- df[ is.na(df[[id_primary]]), ]
	df_update <- df[ ! is.na(df[[id_primary]]), ]
	return_insert <- crud_insert_aincr( conn, df_insert, name )
	crud_update( conn, df_update, name ) # assume nothing is changed
	bind_rows(df_update, return_insert)
}

crud_sync <- crud_sync_asis
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


# rowid -------------------------------------------------------------------

get_rowid_sequence <- function(conn, ...) UseMethod("get_rowid_sequence")

get_rowid_sequence.SQLiteConnection <- function(conn, length_out) {
	last_insert_rowid <- dbGetQuery(conn, "select last_insert_rowid() as rowid;") %>%
		pull(rowid)
	seq(length.out = length_out,
			to         = last_insert_rowid,
			by         = 1L)
}
