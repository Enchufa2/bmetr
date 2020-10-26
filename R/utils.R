#' Find Local Peaks
#'
#' Find local maxima in a neighbourhood. To find local minima, just provide
#' \code{-x} instead of \code{x}.
#'
#' @param x numeric vector.
#' @param m size of the neighbourhood.
#'
#' @return A vector of indices.
#'
#' @references Based on \url{https://github.com/stas-g/findPeaks}.
#'
#' @export
find_peaks <- function(x, m = 3) {
  shape <- diff(sign(diff(x, na.pad = FALSE)))
  unlist(sapply(which(shape < 0), function(i) {
    z <- i - m + 1
    z[z <= 0] <- 1
    w <- i + m + 1
    w[w >= length(x)] <- length(x)
    if(all(x[c(z : i, (i + 2) : w)] <= x[i + 1]))
      return(i + 1)
    return(numeric(0))
  }))
}

# check parity
is.odd <- function(x) x %% 2 != 0

# double factorial
factorial2 <- function(x) {
  odd <- is.odd(x)
  x[odd] <- (x[odd] + 1) / 2
  x[odd] <- gamma(0.5 + x[odd]) * 2^x[odd] / sqrt(pi)
  x[!odd] <- x[!odd] / 2
  x[!odd] <- 2^x[!odd] * factorial(x[!odd])
  x
}

# https://stackoverflow.com/a/4752580/6788081
# Determine if range of vector is FP 0.
zero_range <- function(x, tol = .Machine$double.eps ^ 0.5) {
  if (length(x) == 1) return(TRUE)
  x <- range(x) / mean(x)
  isTRUE(all.equal(x[1], x[2], tolerance = tol))
}
