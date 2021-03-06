# ===========================================================================
# File: "runit_gdi41.R"
#                        Created: 2012-11-13 11:28:57
#              Last modification: 2015-08-31 10:09:41
# Author: Bernard Desgraupes
# e-mail: <bernard.desgraupes@u-paris10.fr>
# Unit test file for the R package clusterCrit.
# ===========================================================================



test.gdi41 <- function() {
	dataPath <- file.path(path.package(package="clusterCrit"),"unitTests","data","testsInternal_400_4.Rdata")
	load(file=dataPath, envir=.GlobalEnv)
	idx <- intCriteria(traj_400_4, part_400_4[[4]], c("GDI41"))
	cat(paste("\nFound idx =",idx))
	val <- 1.7678259229192
	cat(paste("\nShould be =",val,"\n"))
	checkEqualsNumeric(idx[[1]],val)
}


