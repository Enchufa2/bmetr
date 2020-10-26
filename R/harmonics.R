#' Tempo Correction and Smoothing
#'
#' Functions for data cleaning. \code{tmp_rectify} is a general function to
#' rectify a set of tempo harmonics in a sequence given some reference.
#' \code{tmp_rectify_tsig} and \code{tmp_smooth} are wrappers around the latter
#' to rectify a specific set of tempo harmonics given a time signature and to
#' smooth a sequence of tempi respectively. The function \code{tmp_prevalent}
#' is intended to find the most prevalent tempo in a sequence of tempi.
#'
#' @param x a sequence of tempi.
#' @param ref tempo reference(s) for the harmonics.
#' @param harmonics set of tempo harmonics to rectify.
#' @param rtol,rtol2 ratios of tolerance to compute the bounds and determine
#' whether a given tempo is a harmonic of \code{ref}. \code{rtol2} can be
#' specified to implement asymmetric bounds; otherwise, they are symmetric.
#' @param cond condition to apply the correction.
#'
#' @return The rectified sequence, except for \code{tmp_prevalent}, which
#' returns a single value.
#'
#' @export
tmp_rectify <- function(x, ref, harmonics, rtol, rtol2=rtol, cond=any) {
  stopifnot(is.atomic(ref) || length(ref) == length(x))
  stopifnot(is.atomic(rtol), is.atomic(rtol2), is.function(cond))
  ratio <- x / ref
  ratio[is.nan(ratio)] <- Inf
  bounds <- c(rbind(harmonics * (1-rtol), harmonics * (1+rtol2)))
  tryCatch({
    pos <- findInterval(ratio, bounds)
  }, error=function(e) {
    message("harmonics bounds: ", paste(bounds, collapse=" "))
    stop(e)
  })
  if (cond(is.odd(pos))) {
    n <- is.odd(pos)
    x[n] <- x[n] / harmonics[(pos[n]+1)/2]
  }
  x
}

#' @param tsig time signature. Notably, this function distinguishes between
#' binary time signatures (specified by \code{2}), time signatures with ternary
#' subdivision (specified by \code{0.3}).
#'
#' @name tmp_rectify
#' @export
tmp_rectify_tsig <- function(x, ref, tsig, rtol=0.15, rtol2=rtol) {
  stopifnot(zero_range(tsig))
  if (tsig[1] == 2) harmonics <- c(1/2, 2, 3)
  else if (tsig[1] == 0.3) harmonics <- c(1/3, 1/2, 2, 3)
  else harmonics <- c(1/2, 3/2, 3)
  tmp_rectify(x, ref, harmonics, rtol, rtol2)
}

#' @param ref2 additional tempo harmonic to consider.
#' @param nref number of previous samples to take into account.
#'
#' @name tmp_rectify
#' @export
tmp_smooth <- function(x, ref, tsig, rtol=0.1, rtol2=rtol, ref2=1, nref=3) {
  stopifnot(is.atomic(tsig), is.atomic(nref))
  if (length(tsig) == 1) tsig <- rep(tsig, length(x))
  x[1] <- ref[1]
  for (i in nref:length(x)) {
    if (x[i] > ref[i]*1.15 & (tsig[i] == 2 | tsig[i] == 0.3))
      harmonics <- c(2, 3)
    else if (x[i] > ref[i]*1.15 & tsig[i] == 3)
      harmonics <- c(3/2, 2, 3)
    else if (x[i] < ref[i]*0.87 & (tsig[i] == 2 | tsig[i] == 0.3))
      harmonics <- c(1/3, 1/2)
    else if (x[i] < ref[i]*0.87 & tsig[i] == 3)
      harmonics <- c(1/2)
    else if (x[i] < ref[i]*0.87 & tsig[i] == 0 & ref2 < 1)
      harmonics <- ref2
    else if (x[i] > ref[i]*1.15 & tsig[i] == 0 & ref2 > 1)
      harmonics <- ref2
    else next
    cor <- tmp_rectify(x[i], x[seq(i-1, i-nref)], harmonics, rtol, rtol2)
    ind <- which(cor != x[i])
    if (length(ind)) x[i] <- cor[ind[1]]
  }
  x
}

#' @param breaks number of breaks to compute the histogram.
#'
#' @name tmp_rectify
#' @export
tmp_prevalent <- function(x, breaks=30) {
  xh <- graphics::hist(x, breaks, plot = FALSE)
  index <- which.max(xh$density)
  xh$mids[[index]]
}
