get.all.breaks.traditional <-
function(dataset, CycleBreaks=NULL, window=NULL, hz){
  
  if(is.null(CycleBreaks)){
		set1 <- get.cycle.breaks(dataset, window)
		CycleBreaks <- set1$CycleBreaks
		CycleIndex <- set1$CycleIndex
		}
	cyclemat <- get.cycle.matrix(dataset, CycleBreaks)
	min.breaks <- get.cycle.minimums(dataset, CycleBreaks, cyclemat)
	FCSC <- get.transition.locations.FDiff(cyclemat, min.breaks$close.cycle, type="FCSC", CycleBreaks, closebreaks=min.breaks$closebreaks, hz=hz)
	SOFO <- get.transition.locations.FDiff(cyclemat, min.breaks$close.cycle, type="SOFO", CycleBreaks, closebreaks=min.breaks$closebreaks, hz=hz)
	return(list(openbreaks=CycleBreaks, closebreaks=min.breaks$closebreaks, FCSC=FCSC$seq.mat, SOFO=SOFO$seq.mat, cyclemat=cyclemat, close.cycle=min.breaks$close.cycle, FCSC.cycle=FCSC$cycle, SOFO.cycle=SOFO$cycle))
	}

