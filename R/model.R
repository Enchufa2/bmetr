#' Metronome Model
#'
#' Functions to compute a metronome's oscillation frequency. \code{metr_model}
#' is the main function. It computes the base value (\code{metr_model_base}),
#' which includes the contribution of the mass of the rod (\code{mu.}), and
#' applies corrections due to the oscillation angle (\code{metr_model_angle})
#' and the friction (\code{metr_model_friction}).
#'
#' Function \code{metr_model_bias} computes, for a given metronome mark, the
#' resulting oscillation frequency for an alteration of any parameter. To this
#' end, it uses \code{metr_model_r} to first calculate the position of the upper
#' mass for this metronome mark.
#'
#' @param r distance from the shaft to the center of mass of the upper mass, in mm.
#' @param R distance from the shaft to the center of mass of the lower mass, in mm.
#' @param M. nondimensionalized lower mass (lower mass divided by upper mass).
#' @param l length of the rod above the shaft, in mm.
#' @param L length of the rod below the shaft, in mm.
#' @param mu. nondimensionalized rod mass (rod mass divided by upper mass).
#' @param g standard gravity, in m/s^2.
#' @param A oscillation amplitude, in degrees.
#' @param ep0 nondimensional friction parameter (\code{>= 0}).
#' @param terms number of terms to approximate the angle correction.
#'
#' @return \code{metr_model}, \code{metr_model_base} and \code{metr_model_bias}
#' return the oscillation frequency in pulses per minute.
#'
#' \code{metr_model_angle} and \code{metr_model_friction} return a value \code{>= 1}.
#'
#' \code{metr_model_r} returns the distance from the shaft to the upper mass in mm.
#'
#' @details A value of \code{mu.=0} means that the rod is considered massless.
#' A value of \code{A=0} means that no correction is applied due to the
#' oscillation amplitude. A value of \code{ep0=0} means that the movement is
#' frictionless. A value of \code{ep0=0.5} means that the metronome stops due
#' to friction at the lowest possible frequency.
#'
#' To compute the frequency bias for any parameter, two values must be supplied
#' to \code{metr_model_bias}. For example, if the original position of the lower
#' mass is \code{50} mm, and we want to calculate the result of lowering it down
#' \code{5} mm, then \code{R=c(50, 55)} should be supplied.
#'
#' @export
metr_model <- function(r, R=50, M.=5, l=220, L=R, mu.=0, g=9.807, A=0, ep0=0) {
  metr_model_base(r, R, M., l, L, mu., g) /
    metr_model_angle(A) /
    metr_model_friction(r, R, M., l, L, mu., ep0)
}

#' @name metr_model
#' @export
metr_model_base <- function(r, R=50, M.=5, l=220, L=R, mu.=0, g=9.807) {
  sqrt(g*1e3 * (M.*R - mu.*(l-L)/2 - r) / (M.*R^2 + mu.*(L^2+l^2-l*L)/3 + r^2)) *
    60 / pi # to bpm
}

#' @name metr_model
#' @export
metr_model_angle <- function(A, terms=8) {
  n <- 0:terms
  do.call(c, lapply(sin(A/2 * pi/180), function(a)
    sum(a^(2*n) * (factorial2(2*n - 1) / factorial2(2*n))^2)))
}

#' @name metr_model
#' @export
metr_model_friction <- function(r, R=50, M.=5, l=220, L=R, mu.=0, ep0=0){
  stopifnot(ep0 >= 0)
  ep <- ep0 * (1 - (l-r) / (M.*R - r + mu.*(L-l)/2))
  1 + asin(ep / (1 - ep))/pi - asin(ep / (1 + ep))/pi
}

#' @param mark metronome mark, in pulses per minute.
#' @param shift include a shift of the rod with respect to the scale, in mm.
#'
#' @name metr_model
#' @export
metr_model_bias <- function(mark, R=50, M.=5, l=220, L=R, mu.=0, g=9.807, A=0,
                            ep0=0, shift=0)
{
  params <- list(R, M., l, L, mu., g, A)
  params <- lapply(params, function(x) if(is.atomic(x)) c(x, x) else x)
  r <- do.call(metr_model_r, c(list(mark), lapply(params, `[`, 1)))
  do.call(metr_model, c(list(r + shift), lapply(params, `[`, 2), ep0))
}

#' @name metr_model
#' @export
metr_model_r <- function(mark, R=50, M.=5, l=220, L=R, mu.=0, g=9.807, A=0) {
  o2g <- (mark * pi/60 * metr_model_angle(A))^2 / (g*1e3)
  (sqrt(1 - 4*o2g^2 * (M.*R^2 + mu.*(L^2 + l^2 - L*l) / 3) +
          4*o2g * (M.*R - mu.*(l-L)/2)) - 1) / o2g / 2
}

#' Metronome Model Fit
#'
#' Fit metronome's nondimensionalized masses, \code{M.} and \code{m.} (see
#' \code{\link{metr_model}}), from a set of measurements and parameters.
#'
#' @param .data measurements of distance to the shaft for each metronome mark.
#' It must contain the variables \code{model}, \code{mark} and \code{r}, as,
#' e.g., the \code{\link{metr.marks}} data set.
#' @param params the rest of the dimensions: correction of the center of mass
#' of the upper mass \code{rcm}, length of the rod above the shaft \code{l},
#' length of the rod below the shaft \code{L}, distance of the lower mass to
#' the shaft \code{R} and oscillation amplitude \code{A}, as, e.g., the
#' \code{\link{metr.params}} data set.
#' @param by variable to group by; e.g., the metronome model, to fit
#' several metronomes.
#'
#' @return A grouped data frame with \code{model}, \code{M.} (and error),
#' \code{mu.} (and error) and the \code{fit} object.
#'
#' @export
metr_fit <- function(.data, params, by="model") {
  if (isTRUE(by %in% names(.data)))
    .data <- dplyr::group_by(.data, .data[[by]])

  dplyr::group_modify(separate_errors(.data), ~ {
    params <- unite_errors(subset(params, model==.y$model[1]))
    .x <- unite_errors(.x)

    g <- errors::set_errors(9807, 40) / metr_model_angle(params$A)^2
    r <- .x$r + params$rcm
    o2 <- (.x$mark * pi/60)^2
    fit <- stats::lm(o2 ~ I(g*r + o2*r^2))

    coef <- errors::set_errors(stats::coef(fit), sqrt(diag(stats::vcov(fit))))
    a <- coef[[1]]
    b <- coef[[2]]
    errors::covar(a, b) <- stats::vcov(fit)[2]
    c <- with(params, b*g*(R^2 - R*l - 2*l^2))

    M. <- with(params, (2*a*(R^2 - R*l + l^2) + 3*g*(l - R)) / (R*c))
    mu. <- with(params, 6*(g - a*R)/c)

    df <- separate_errors(data.frame(M., mu.))
    df$fit <- list(fit)
    df
  })
}

#' @param .fit output from \code{metr_fit}.
#'
#' @name metr_fit
#' @export
metr_predict <- function(.fit, by="model") {
  .data <- NULL
  if (isTRUE(by %in% names(.fit)))
    .fit <- dplyr::group_by(.fit, .data[[by]])

  dplyr::group_modify(.fit, ~ {
    y <- model.frame(.x$fit[[1]])[[1]]
    pred <- predict(.x$fit[[1]], interval="confidence")
    cbind(y=y, as.data.frame(pred))
  })
}
