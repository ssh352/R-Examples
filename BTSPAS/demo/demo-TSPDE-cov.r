# 2014-09-01 CJS Removed prompts from demo file. SHowed optional call to openbugs
# 2009-12-01

# This is a demonstration of how to call the Time Stratified Petersen with Diagonal Entries (TSPDE) program
# INCLUDING A COVARIATE TO MODEL CATCHABILITY.

# It is based on the analysis of California Junction City 2003 Chinook data and is the example used
# in the Trinity River Project.
#
# In each julian week j, n1[j] are marked and released above the rotary screw trap.
# Of these, m2[j] are recaptured. All recaptures take place in the week of release, i.e. the matrix of
# releases and recoveries is diagonal.
# The n1[j] and m2[j] establish the capture efficiency of the trap.
#
# At the same time, u2[j] unmarked fish are captured at the screw trap.
# The simple stratified Petersen estimator would inflate the u2[j] buy 1/capture efficiency[j]
# giving U2[j] = total fish passing the trap in julian week [j] = u2[j] * n1[j]/ m2[j].
#
# The program assumes that the trap was operating all days of the week. The sampfrac[j] variable
# gives the proportion of days the trap was operating. For example, if the trap was operating for 3 of the
# 7 days in a week, then sampfrac[j]<- 3/7
#
# The covariate used to model catchability is the log(flow) as measured at a nearby USGS gauge station.
#
#
# Notes:
#    - the number of recaptures in sample week 33 (julian week 41) is far too low. 
#      This leads to an estimate of almost 13 million fish from the simple stratified Petersen. 
#      Consequently, the recaptures for this
#      week are set to missing and the program will interpolate the number of fish for this week
#
#    - the number of days operating is 8 in sample weeks 2 (julian week 10) and 
#      6 in sample week 3 (julian week 11). The 8 days in sample week 2 is "real" as
#      the code used on the marked fish was used for 8 days. The program will automatically 
#      "reduce" the number of unmarked fish captured in this week to a "7" day week 
#      and will increase the number of unmarked fish captured in week 3 to "7" days as well. 
# 
#  The program tries to fit a single spline to the entire dataset. However, in julian weeks
#  23 and 40, hatchery released fish started to arrive at the trap resulting in sudden jump
#  in abundance. The jump.after vector gives the julian weeks just BEFORE the suddent jump,
#  i.e. the spline is allowed to jump AFTER the julian weeks in jump.after.
#
#  The vector bad.m2 indicates which julian weeks something went wrong. For example, the
#  number of recoveries in julian week 41 is far below expectations and leads to impossible
#  Petersen estimate for julian week 41.
# 
#  The prefix is used to identify the output files for this run.
#  The title  is used to title the output.

## Load BTSPAS library
library(BTSPAS)

# Create a directory to store the results Test and then create the
# directory
if(file.access("demo-TSPDE-cov")!=0){ dir.create("demo-TSPDE-cov", showWarnings=TRUE) }
setwd("demo-TSPDE-cov")

# Get the data. In many cases, this is stored in a *.csv file and read into the program
# using a read.csv() call. In this demo, the raw data is assigned directly as a vector.
#

# Indicator for the week.
demo.jweek <- c(9,   10,   11,   12,   13,   14,   15,   16,   17,   18,
          19,   20,   21,   22,   23,   24,   25,   26,   27,   28, 
          29,   30,   31,   32,   33,   34,   35,   36,   37,   38,
          39,   40,   41,   42,   43,   44,   45,   46)

# Number of marked fish released in each week.
demo.n1 <- c(   0, 1465, 1106,  229,   20,  177,  702,  633, 1370,  283,
         647,  276,  277,  333, 3981, 3988, 2889, 3119, 2478, 1292,
        2326, 2528, 2338, 1012,  729,  333,  269,   77,   62,   26,
          20, 4757, 2876, 3989, 1755, 1527,  485,  115)

# Number of marked fish recaptured in the week of release. No marked fish
# are recaptured outside the week of release.
demo.m2 <- c(   0,   51,  121,   25,    0,   17,   74,   94,   62,   10,
          32,   11,   13,   15,  242,   55,  115,  198,   80,   71, 
         153,  156,  275,  101,   66,   44,   33,    7,    9,    3,
           1,  188,    8,   81,   27,   30,   14,    4)

# Number of unmarked fish captured at the trap in each week.
demo.u2 <- c(4135,10452, 2199,  655,  308,  719,  973,  972, 2386,  469,
         897,  426,  407,  526,39969,17580, 7928, 6918, 3578, 1713, 
        4212, 5037, 3315, 1300,  989,  444,  339,  107,   79,   41,
          23,35118,34534,14960, 3643, 1811,  679,  154)

# What fraction of the week was sampled?
demo.sampfrac<-c(3,   8,    6,    7,    7,    7,    7,    7,    7,    7,
            7,   7,    7,    7,    7,    7,    7,    7,    7,    7,
            6,   7,    7,    7,    7,    7,    7,    7,    7,    7,
            7,   7,    7,    7,    7,    7,    7,    5)/7

# After which weeks is the spline allowed to jump?
demo.jump.after <- c(22,39)  # julian weeks after which jump occurs

# Which julian weeks have "bad" recapture values. These will be set to missing and estimated.
demo.bad.m2     <- c(41)   # list julian week with bad m2 values
 
# The covariate vector. This is a length(n1) x 2 vector with the first column being the intercept
# and the second column being the log(flow)
demo.logitP.cov <- matrix(c(
    1, 6.617212, 1, 6.512170, 1, 7.193686, 1, 6.960754, 1, 7.008376,
    1, 6.761573, 1, 6.905753, 1, 7.062314, 1, 7.600188, 1, 8.246509,
    1, 8.110298, 1, 8.035001, 1, 7.859965, 1, 7.774255, 1, 7.709116,
    1, 7.653766, 1, 7.622105, 1, 7.593734, 1, 7.585063, 1, 7.291072,
    1, 6.555560, 1, 6.227665, 1, 6.278789, 1, 6.273685, 1, 6.241111,
    1, 6.687999, 1, 7.222566, 1, 7.097194, 1, 6.949993, 1, 6.168714,
    1, 6.113682, 1, 6.126557, 1, 6.167217, 1, 5.862413, 1, 5.696614,
    1, 5.763847, 1, 5.987528, 1, 5.912344), nrow=length(demo.n1), ncol=2, byrow=TRUE)


# The prefix for the output files:
demo.prefix <- "demo-JC-2003-CH-TSPDE-flow" 

# Title for the analysis
demo.title <- "Junction City 2003 Chinook using log(FLOW) as a covariate for logit(P) "




cat("*** Starting ",demo.title, "\n\n")

# Make the call to fit the model and generate the output files
demo.jc.2003.ch.tspde.flow <- TimeStratPetersenDiagError_fit(
                  title=demo.title,
                  prefix=demo.prefix,
                  time=demo.jweek,
                  n1=demo.n1, 
                  m2=demo.m2, 
                  u2=demo.u2,
                  logitP.cov=demo.logitP.cov,
                  sampfrac=demo.sampfrac,
                  jump.after=demo.jump.after,
                  bad.m2=demo.bad.m2,
		  #engine="openbugs",  # how to call openbugs
                  debug=TRUE  # this generates only 10,000 iterations of the MCMC chain for checking.
                  )

demo.jc.2003.ch.tspde.flow.row.names <- rownames(demo.jc.2003.ch.tspde.flow$summary)
demo.coeff.row.index <- grep("beta.logitP[", demo.jc.2003.ch.tspde.flow.row.names, fixed=TRUE)
demo.coeff.row.index <- demo.coeff.row.index[1:2] # the 3rd index is a dummy value needed when there is a single beta
demo.coeff    <- demo.jc.2003.ch.tspde.flow$summary[demo.coeff.row.index,"mean"]
demo.coeff.sd <- demo.jc.2003.ch.tspde.flow$summary[demo.coeff.row.index, "sd"]

demo.pred.logitP <- demo.logitP.cov %*% demo.coeff

demo.logitP.row.index <- grep("^logitP", demo.jc.2003.ch.tspde.flow.row.names)
demo.logitP <- demo.jc.2003.ch.tspde.flow$summary[demo.logitP.row.index, "mean"]   # extract the logit(P) values

pdf(file=paste(demo.prefix,"-fitflow.pdf",sep=""))
plot( demo.logitP.cov[,2], demo.logitP, type="p", main="logitP vs log(flow) with fitted line")
abline( a=demo.coeff[1], b=demo.coeff[2]) 
demo.jc.2003.ch.tspde.flow.text<-paste("Int       (SD):",round(demo.coeff[1],3),"  ",round(demo.coeff.sd[1],3),"\n",
                 "Slope (SD):",round(demo.coeff[2],3),"  ",round(demo.coeff.sd[2],3), se="")
text( x=min(demo.logitP.cov[,2])+.80*(max(demo.logitP.cov[,2])-min(demo.logitP.cov[,2])),
      y=min(demo.logitP)+        .90*(max(demo.logitP)-min(demo.logitP)),
      labels=c(demo.jc.2003.ch.tspde.flow.text))
dev.off()


# Rename files that were created.

file.copy("data.txt",       paste(demo.prefix,".data.txt",sep=""),      overwrite=TRUE)
file.copy("CODAindex.txt",  paste(demo.prefix,".CODAindex.txt",sep=""), overwrite=TRUE)
file.copy("CODAchain1.txt", paste(demo.prefix,".CODAchain1.txt",sep=""),overwrite=TRUE)
file.copy("CODAchain2.txt", paste(demo.prefix,".CODAchain2.txt",sep=""),overwrite=TRUE)
file.copy("CODAchain3.txt", paste(demo.prefix,".CODAchain3.txt",sep=""),overwrite=TRUE)
file.copy("inits1.txt",     paste(demo.prefix,".inits1.txt",sep=""),    overwrite=TRUE)
file.copy("inits2.txt",     paste(demo.prefix,".inits2.txt",sep=""),    overwrite=TRUE)
file.copy("inits3.txt",     paste(demo.prefix,".inits3.txt",sep=""),    overwrite=TRUE)

file.remove("data.txt"       )       
file.remove("CODAindex.txt"  )
file.remove("CODAchain1.txt" )
file.remove("CODAchain2.txt" )
file.remove("CODAchain3.txt" )
file.remove("inits1.txt"     )
file.remove("inits2.txt"     )
file.remove("inits3.txt"     )
 
# save the results in a data dump that can be read in later using the load() command.
# Contact Carl Schwarz (cschwarz@stat.sfu.ca) for details.
save(list=c("demo.jc.2003.ch.tspde.flow"), file="demo-jc-2003-ch-tspde-flow-saved.Rdata")  # save the results from this run

cat("\n\n\n ***** FILES and GRAPHS saved in \n    ", getwd(), "\n\n\n")
print(dir())

# move up the directory
setwd("..")


cat("\n\n\n ***** End of Demonstration *****\n\n\n")
