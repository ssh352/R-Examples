
#' @title Merge Data across Stochastic Individual Contact Model Simulations
#'
#' @description Merges epidemiological data from two independent simulations of
#'              stochastic individual contact models from \code{icm}.
#'
#' @param x An \code{EpiModel} object of class \code{\link{icm}}.
#' @param y Another \code{EpiModel} object of class \code{\link{icm}}, with the
#'        identical model parameterization as \code{x}.
#' @param ...  Additional merge arguments (not used).
#'
#' @details
#' This merge function combines the results of two independent simulations of
#' \code{\link{icm}} class models, simulated under separate function calls. The
#' model parameterization between the two calls must be exactly the same, except
#' for the number of simulations in each call. This allows for manual
#' parallelization of model simulations.
#'
#' This merge function does not work the same as the default merge in allowing
#' for a combined object where the structure differs between the input elements.
#' Instead, the function checks that objects are identical in model
#' parameterization in every respect (except number of simulations) and binds
#' the results.
#'
#' @method merge icm
#' @keywords extract
#' @export
#'
#' @examples
#' param <- param.icm(inf.prob = 0.2, act.rate = 0.8)
#' init <- init.icm(s.num = 1000, i.num = 100)
#' control <- control.icm(type = "SI", nsteps = 10,
#'                        nsims = 3, verbose = FALSE)
#' x <- icm(param, init, control)
#'
#' control <- control.icm(type = "SI", nsteps = 10,
#'                        nsims = 1, verbose = FALSE)
#' y <- icm(param, init, control)
#'
#' z <- merge(x, y)
#' x$epi
#' y$epi
#' z$epi
#'
merge.icm <- function(x, y, ...) {

  ## Check structure
  if (length(x) != length(y) || names(x) != names(y)) {
    stop("x and y have different structure")
  }
  if (x$control$nsims > 1 & y$control$nsims > 1 &
      !all(sapply(x, class) == sapply(y, class))) {
    stop("x and y have different structure")
  }


  ## Check params
  check1 <- identical(x$param, y$param)
  check2 <- identical(x$control[-which(names(x$control) == "nsims")],
                      y$control[-which(names(y$control) == "nsims")])

  if (check1 == FALSE) {
    stop("x and y have different parameters")
  }
  if (check2 == FALSE) {
    stop("x and y have different controls")
  }


  z <- x
  new.range <- (x$control$nsims + 1):(x$control$nsims + y$control$nsims)

  # Merge data
  for (i in 1:length(x$epi)) {
    if (x$control$nsims == 1) {
      x$epi[[i]] <- data.frame(x$epi[[i]])
    }
    if (y$control$nsims == 1) {
      y$epi[[i]] <- data.frame(y$epi[[i]])
    }
    z$epi[[i]] <- cbind(x$epi[[i]], y$epi[[i]])
    names(z$epi[[i]])[new.range] <- paste0("sim", new.range)
  }

  z$control$nsims <- max(new.range)

  return(z)
}


#' @title Merge Model Simulations Across netsim Objects
#'
#' @description Merges epidemiological data from two independent simulations of
#'              stochastic network models from \code{netsim}.
#'
#' @param x An \code{EpiModel} object of class \code{\link{netsim}}.
#' @param y Another \code{EpiModel} object of class \code{\link{netsim}},
#'        with the identical model parameterization as \code{x}.
#' @param keep.transmat If \code{TRUE}, keep the transmission matrices from the
#'        original \code{x} and \code{y} elements.
#' @param keep.network If \code{TRUE}, keep the \code{networkDynamic} objects
#'        from the original \code{x} and \code{y} elements.
#' @param keep.nwstats If \code{TRUE}, keep the network statistics (as set by
#'        the \code{nwstats.formula} parameter in \code{control.netsim}) from
#'        the original \code{x} and \code{y} elements.
#' @param keep.other If \code{TRUE}, keep the other simulation elements (as set
#'        by the \code{save.other} parameter in \code{control.netsim}) from the
#'        original \code{x} and \code{y} elements.
#' @param param.error If \code{TRUE}, if \code{x} and \code{y} have different
#'        params (in \code{param.net}) or controls (passed in \code{control.net})
#'        an error will prevent the merge. Use \code{FALSE} to override that
#'        check.
#' @param ...  Additional merge arguments (not currently used).
#'
#' @details
#' This merge function combines the results of two independent simulations of
#' \code{\link{netsim}} class models, simulated under separate function calls. The
#' model parameterization between the two calls must be exactly the same, except
#' for the number of simulations in each call. This allows for manual
#' parallelization of model simulations.
#'
#' This merge function does not work the same as the default merge in
#' allowing for a combined object where the structure differs between the
#' input elements. Instead, the function checks that objects are identical
#' in model parameterization in every respect (except number of simulations) and
#' binds the results.
#'
#' @method merge netsim
#' @keywords extract
#' @export
#'
#' @examples
#' # Network model
#' nw <- network.initialize(n = 100, directed = FALSE)
#' coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 10)
#' est <- netest(nw, formation = ~edges, target.stats = 25,
#'               coef.diss = coef.diss, verbose = FALSE)
#'
#' # Epidemic models
#' param <- param.net(inf.prob = 1)
#' init <- init.net(i.num = 1)
#' control <- control.net(type = "SI", nsteps = 20, nsims = 2,
#'                        save.nwstats = TRUE,
#'                        nwstats.formula = ~edges + degree(0),
#'                        verbose = FALSE)
#' x <- netsim(est, param, init, control)
#' y <- netsim(est, param, init, control)
#'
#' # Merging
#' z <- merge(x, y)
#' x$epi
#' y$epi
#' z$epi
#'
merge.netsim <- function(x, y, keep.transmat = TRUE, keep.network = TRUE,
                         keep.nwstats = TRUE, keep.other = TRUE,
                         param.error = TRUE, ...) {

  ## Check structure
  if (length(x) != length(y) || names(x) != names(y)) {
    stop("x and y have different structure")
  }
  x$control$nsims <- as.integer(x$control$nsims)
  y$control$nsims <- as.integer(y$control$nsims)
  if (x$control$nsims > 1 & y$control$nsims > 1 &
      !all(sapply(x, function(i) class(i)[1]) == sapply(y, function(i) class(i)[1]))) {
    stop("x and y have different structure")
  }

  # Override environment of nwstats.formula
  if (!is.null(x$control$nwstats.formula) & !is.null(y$control$nwstats.formula)) {
    environment(x$control$nwstats.formula) <-
      environment(y$control$nwstats.formula) <- environment()
  }


  ## Check params
  check1 <- identical(x$param, y$param)
  check2 <- identical(x$control[-which(names(x$control) == "nsims")],
                      y$control[-which(names(y$control) == "nsims")])


  if (check1 == FALSE && param.error == TRUE) {
    stop("x and y have different parameters")
  }
  if (check2 == FALSE && param.error == TRUE) {
    stop("x and y have different controls")
  }


  z <- x
  new.range <- (x$control$nsims + 1):(x$control$nsims + y$control$nsims)

  # Merge epi data
  for (i in 1:length(x$epi)) {
    z$epi[[i]] <- cbind(x$epi[[i]], y$epi[[i]])
    names(z$epi[[i]])[new.range] <- paste0("sim", new.range)
  }

  z$control$nsims <- max(new.range)


  ## Transmission matrix
  if (keep.transmat == TRUE) {
    for (i in new.range) {
      if (!is.null(x$stats$transmat) & !is.null(y$stats$transmat)) {
        z$stats$transmat[[i]] <- y$stats$transmat[[i - x$control$nsims]]
        if (!is.null(z$stats$transmat)) {
          names(z$stats$transmat)[i] <- paste0("sim", i)
        }
      }
    }
  } else {
    z$stats$transmat <- NULL
  }


  ## Network objects
  if (keep.network == TRUE & !is.null(x$network) & !is.null(y$network)) {
    for (i in new.range) {
      z$network[[i]] <- y$network[[i - x$control$nsims]]
      if (!is.null(z$network)) {
        names(z$network)[i] <- paste0("sim", i)
      }
    }
  } else {
    z$network <- NULL
  }


  ## Network statistics
  if (keep.nwstats == TRUE & !is.null(x$stats$nwstats) & !is.null(y$stats$nwstats)) {
    for (i in new.range) {
      z$stats$nwstats[[i]] <- y$stats$nwstats[[i - x$control$nsims]]
      if (!is.null(z$stats$nwstats)) {
        names(z$stats$nwstats)[i] <- paste0("sim", i)
      }
    }
  } else {
    z$stats$nwstats <- NULL
  }

  ## Other
  if (!is.null(x$control$save.other) & !is.null(y$control$save.other)) {
    other.x <- x$control$save.other
    other.y <- y$control$save.other
    if (keep.other == TRUE) {
      if (!identical(other.x, other.y)) {
        stop("Elements in save.other differ between x and y", call. = FALSE)
      }
      for (j in 1:length(other.x)) {
        for (i in new.range) {
          z[[other.x[j]]][[i]] <- y[[other.x[j]]][[i - x$control$nsims]]
        }
      }
    } else {
      for (j in 1:length(other.x)) {
        z[[other.x[j]]] <- NULL
      }
    }
  }


  return(z)
}
