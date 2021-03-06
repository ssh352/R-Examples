#' magrittr - Ceci n'est pas un pipe
#'
#' The magrittr package offers a set of operators which promote semantics 
#' that will improve your code by
#' \itemize{
#'   \item structuring sequences of data operations left-to-right
#'         (as opposed to from the inside and out),
#'   \item avoiding nested function calls, 
#'   \item minimizing the need for local variables and function definitions, and
#'   \item making it easy to add steps anywhere in the sequence of operations.
#' }
#' The operators pipe their left-hand side values forward into expressions that
#' appear on the right-hand side, i.e. one can replace \code{f(x)} with 
#' \code{x \%>\% f}, where \code{\%>\%} is the (main) pipe-operator.
#' \cr\cr
#' Consider the example below. Four operations are performed to 
#' arrive at the desired data set, and they are written in a natural order: 
#' the same as the order of execution. Also, no temporary variables are needed.
#' If yet another operation is required, it is straight-forward to add to the
#' sequence of operations whereever it may be needed.
#' \cr\cr
#' For a more detailed introduction see the vignette 
#' (\code{vignette("magrittr")}) or the documentation pages for the
#' available operators:\cr
#' \tabular{ll}{
#'    \code{\link{\%>\%}}  \tab forward-pipe operator.\cr
#'    \code{\link{\%T>\%}} \tab tee operator.\cr
#'    \code{\link{\%<>\%}} \tab compound assignment pipe-operator.\cr
#'    \code{\link{\%$\%}}  \tab exposition pipe-operator.\cr
#' }
#' 
#' @examples
#' \dontrun{
#' 
#' the_data <-
#'   read.csv('/path/to/data/file.csv') %>%
#'   subset(variable_a > x) %>%
#'   transform(variable_c = variable_a/veraiable_b) %>%
#'   head(100)
#' }
#' @docType package
#' @name magrittr
NULL