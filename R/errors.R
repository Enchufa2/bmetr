#' Data Wrangling with \pkg{errors}
#'
#' Auxiliary functions to perform some common data wrangling operations in an
#' \pkg{errors}-aware fashion, i.e., to preserve uncertainty metadata.
#'
#' @param .data a data frame.
#' @param key,value names of the new key and value columns, as strings.
#' @param ... a selection of columns to gather.
#'
#' @details \code{gather_errors} is the \pkg{errors}-aware equivalent to
#' \code{tidyr::gather}.
#'
#' \code{unite_errors} and \code{separate_errors} are similar to
#' \code{tidyr::unite} and \code{tidyr::separate}, but only for \code{errors}
#' objects. For example, for each variable \code{var} of class \code{errors},
#' \code{separate_errors} will store the numeric value in \code{var} and will
#' create another variable called \code{var.se} for the errors. Similarly, for
#' each pair of variables \code{var} and \code{var.se}, \code{unite_errors} will
#' store an \code{errors} object in \code{var} and will remove \code{var.se}.
#' Note that the suffix \code{.se} can be changed.
#'
#' @name errors
#' @export
gather_errors <- function(.data, key, value, ...) {
  key_vec <- do.call(c, lapply(c(...), function(i) rep(i, nrow(.data))))
  value_vec <- do.call(c, lapply(c(...), function(i) .data[[i]]))
  for (i in c(...)) .data[[i]] <- NULL
  .data <- .data[rep(1:nrow(.data), length(c(...))),]
  .data[[key]] <- key_vec
  .data[[value]] <- value_vec
  .data
}

#' @param suffix suffix for the error column(s).
#' @name errors
#' @export
unite_errors <- function(.data, suffix=".se") {
  se <- grep(suffix, names(.data))
  for (x.se in names(.data)[se]) {
    x <- sub(suffix, "", x.se)
    .data[[x]] <- errors::set_errors(.data[[x]], .data[[x.se]])
    .data[[x.se]] <- NULL
  }
  .data
}

#' @name errors
#' @export
separate_errors <- function(.data, suffix=".se") {
  for (x in names(.data)) {
    if (!inherits(.data[[x]], "errors"))
      next
    x.se <- paste0(x, suffix)
    .data[[x.se]] <- errors::errors(.data[[x]])
    .data[[x]] <- errors::drop_errors(.data[[x]])
    x.pos <- which(names(.data) == x)
    ind_before <- seq_len(x.pos)
    ind_after <- if (x.pos+1 < ncol(.data))
      seq(x.pos+1, ncol(.data)-1) else integer()
    .data <- .data[, c(ind_before, ncol(.data), ind_after)]
  }
  .data
}
