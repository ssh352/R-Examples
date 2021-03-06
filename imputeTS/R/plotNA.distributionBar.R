#' @title Visualize Distribution of Missing Values (Barplot)
#' 
#' @description Visualization of missing values in barplot form. Especially useful for
#' time series with a lot of observations.
#' 
#' @param x Numeric Vector (\code{\link{vector}}) or Time Series (\code{\link{ts}}) object containing NAs
#' 
#' @param breaks Defines the number of bins to be created. If breaksize isn't NULL it is overpowered
#' by this parameter
#' 
#' @param breaksize Defines how many observations should be in one bin. The required number of 
#' overall bins is afterwards calculated automatically.
#'  
#' @param percentage Whether the NA / non-NA ration should be given as percent or absolute numbers
#' 
#' @param legend If TRUE a legend is shown at the bottom of the plot. A custom legend can be obtained by
#'  setting this parameter to FALSE and using  \code{\link[graphics]{legend}} function
#' 
#' @param axis If TRUE a axis with labels is added. A custom axis can be obtained by
#'  setting this parameter to FALSE and using  \code{\link[graphics]{axis}} function
#' @param space The amount of space (as a fraction of the average bar width) left before each bar.
#' @param col A vector of colors for the bars or bar components.
#' @param main Main title for the plot
#' @param xlab Label for x axis of the plot
#' @param ylab Label for y axis of plot
#' @param ... Additional graphical parameters that can be passed through to barplot 
#' 
#' @details This function visualizes the distribution of missing values within a time series. Therefore
#' the time series is plotted and whenever a value is NA the background is colored differently.
#' This gives a nice overview, where in the time series most of the missing values occur.
#'
#' @author Steffen Moritz
#' 
#' @seealso \code{\link[imputeTS]{plotNA.distribution}},
#'  \code{\link[imputeTS]{plotNA.gapsize}}, \code{\link[imputeTS]{plotNA.imputations}}
#' 
#' @examples
#' #Prerequisite: Load a time series with missing values
#' x <- tsHeating
#' 
#' #Example 1: Visualize the missing values in this time series
#' plotNA.distributionBar(x, breaks = 20)
#' 
#' @importFrom graphics legend barplot axis par plot
#' @export plotNA.distributionBar

plotNA.distributionBar <- function(x, 
                                    breaks = 10, breaksize = NULL, percentage = T, legend = T,
                                    axis =T, space =0, col=c('indianred2','green2'), main = "Distribution of NAs", xlab ="Time", ylab=NULL ,  ... ) {
  
  data <- x
  
  #Check for wrong input 
  data <- precheck(data)
  
  inputTS <- data
  
  #save par settings and reset after function
  par.default <- par(no.readonly=TRUE) 
  on.exit(par(par.default))
  
  
  
  #Calculate the breakssize from the demanded breaks
  if (is.null(breaksize)) {
    breaksize <- ceiling(length(inputTS) / breaks)
  }
  
  breakpoints <- c(1)
  bp <- 1
  while ( bp < length(inputTS))
  {
    bp <- bp+ breaksize
    if (bp >= length(inputTS))
    { bp <- length(inputTS) }
    breakpoints <- c(breakpoints,bp)  
  }
  
  #Define the width of the last bin in order to make it smaller if it contains less values
  widthLast <- (breakpoints[length(breakpoints)] - breakpoints[length(breakpoints)-1]) / (breakpoints[2] - breakpoints[1])
  
  #calculate NA/non-NA ratio inside of every bin
  naAmount <- numeric(0)
  okAmount <- numeric(0)
  for (i in 1:(length(breakpoints)-1)) {
    
    cut <- inputTS[(breakpoints[i]+1):(breakpoints[i+1])]
    
    nas <- length(which(is.na(cut)))
    naAmount <- c(naAmount,nas )
    
    oks <- length(cut) - nas
    okAmount <- c(okAmount, oks )
    
  }
  
  #calculate percentages if wanted 
  if (percentage == T) {
    
    temp1 <- naAmount/(okAmount+naAmount)
    temp2 <- okAmount/(okAmount+naAmount)
    naAmount[is.infinite(naAmount)] <- 1 
    okAmount[is.infinite(okAmount)] <- 1 
    naAmount <- temp1
    okAmount <- temp2
    ylab1 <- "Percentage"
    
  } else if(percentage == F) {
    ylab1 <- "Number"
  }
  
  #check if ylab is pre set
  if (is.null(ylab)) {
    ylab <- ylab1
  }
  
  #create data to be plotted
  data <- matrix(c(naAmount,okAmount),byrow=TRUE,ncol=length(naAmount))
  
  if (legend == T) { par(oma =c(0.5,0,0,0)) }
  
  #create the barplot
  barplot(data,width =c(rep(1,length(naAmount)-1),widthLast) , main =main, space =space,col=col,xlab =xlab,ylab=ylab, ...)
  
  #add axis
  if(axis ==T) {
    axis(1, at=c(seq(0,length(naAmount))), labels = breakpoints, line = 0.5, tick = T)
  }
  #add legend if wanted
 
  if (legend == T) {
    par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)
    plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
    legend("bottom",  bty ='n',xjust =0.5, horiz = T , cex=1, legend = c("NAs","non-NAs"), col = c("indianred2","green2"), pch = c(15))
  }
  
  
  
}




