#' extract aliquots
#'
#' This function extracts a list of aliquots from a \code{\linkS4class{TLum.Analysis}} object.
#'
#' @param object
#'  \code{\linkS4class{TLum.Analysis}} (\bold{required}): object containing the initial TL curves.
#' @param list
#'  \link{numeric}  (\bold{required}): list containing the position of the aliquots that shall be used.
#'
#' @return
#'  This function provides a \code{\linkS4class{TLum.Data.Curve}} object containing only the aliquots specified in the list.
#'
#' @author David Strebler, University of Cologne (Germany).
#'
#' @export mod_extract.aliquot

mod_extract.aliquot <- function(

  object,

  list

){
  # ------------------------------------------------------------------------------
  # Integrity Check
  # ------------------------------------------------------------------------------
  if (missing(object)){
    stop("[mod_update.dType] Error: Input 'object' is missing.")
  }else if (!is(object,"TLum.Analysis")){
    stop("[mod_update.dType] Error: Input 'object' is not of type 'TLum.Analysis'.")
  }

  if(!is.numeric(list)){
    stop("[mod_extract.aliquot] Error: Input 'list' is not of type 'numeric'.")
  }
  # ------------------------------------------------------------------------------

  protocol <- object@protocol
  nRecord <- length(object@records)

  temp.id <- 0

  new.records <- list()

  for(i in 1:nRecord){

    temp.curve <- object@records[[i]]
    temp.position <- temp.curve@metadata$POSITION

    if(temp.position %in% list) {

      temp.id <- temp.id+1

      temp.curve@metadata$ID <- temp.id

      new.records <- c(new.records, temp.curve)

    }
  }

  new.analysis <- set_TLum.Analysis(records = new.records,
                                    protocol = protocol)

  return(new.analysis)
}
