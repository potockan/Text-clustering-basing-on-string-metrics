#from RPKG


#' @title Send an SQL query to PostgreSQL db and clear the results
#'
#' @param con database connection handler
#' @param str single string; SQL query
#' @param get_affected_rows logical
#' @return nothing interesting (get_affected_rows=FALSE)
#' or the number of affected rows
#'
#' @export
dbExecQuery <- function(con, str, get_affected_rows=FALSE) {
  stopifnot(is.character(str), length(str)==1)
  res <- dbSendQuery(con, str)
  if (identical(TRUE, get_affected_rows)) {
    afrows <- dbGetRowsAffected(res)
    invisible(dbClearResult(res))
    afrows
  }
  else {
    invisible(dbClearResult(res))
    invisible(NULL)
  }
}
