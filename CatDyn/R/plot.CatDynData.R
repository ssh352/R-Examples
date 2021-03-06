plot.CatDynData <-
function(x,mark,offset,hem,...)
    {
     options(warn=-1)
     if(class(x) != "CatDynData") {stop("Pass and object of class CatDynData as first argument - see the help for as.CatDynData")}
     fleet.name <- x$Properties$Fleets$Fleet
     for(i in 1:length(fleet.name))
       {
       period <- x$Data[[i]][,1]
       effort <- x$Data[[i]][,2]
       catch  <- x$Data[[i]][,5]
       spike  <- x$Data[[i]][,6] 
       mbw    <- x$Data[[i]][,4] 
       tstep  <- x$Properties$Units[1]
       layout(matrix(c(1,2,3,4,4,4,5,5,5,6,6,6,7,7,7),5,3, byrow = TRUE))
       par(oma=c(2,2,2,1), mar=c(4,4,2,2))
       plot(x=effort,y=catch,main="",xlab=paste("Effort (",x$Properties$Fleets[i,"Units"],")",sep=""),ylab=paste("Catch (",x$Properties$Units[4],")",sep="")) 
       hist(x=catch,main="",xlab=paste("Catch (",x$Properties$Units[4],")",sep=""),ylab="Frequency")
       hist(x=effort,main="",xlab=paste("Effort (",x$Properties$Fleets[i,"Units"],")",sep=""),ylab="Frequency")
       plot(x=period,y=effort,xlab=gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", tstep, perl=TRUE),ylab=paste("Effort (",x$Properties$Fleets[i,"Units"],")",sep=""),axes=FALSE, pch=19)
       if(mark==TRUE)
         {
          text(x=period,y=effort+max(effort)/offset[1],labels=period)
         } 
       axis(side=1,at=seq(head(period,1),tail(period,1),1))
       axis(side=2,at=NULL)
       #obseff.trend    <- loess(effort~period,span=span)
       #obseff.pred     <- predict(obseff.trend)
       #lines(x=period,y=obseff.pred,col="blue",lwd=1)
       if(hem=="N")
         {
         if(tstep=="day")
           {
           text(x=079+10,y=0.9*max(effort),lab="Spring",col='blue')
           text(x=171+10,y=0.9*max(effort),lab="Summer",col='blue')
           text(x=263+10,y=0.9*max(effort),lab="Fall",col='blue')
           text(x=354+10,y=0.9*max(effort),lab="Winter",col='blue')
           abline(v=079,col='blue')
           abline(v=171,col='blue')
           abline(v=263,col='blue')
           abline(v=354,col='blue')
           }
         else if(tstep=="week")
           {
           text(x=12+2,y=0.9*max(effort),lab="Spring",col='blue')
           text(x=25+2,y=0.9*max(effort),lab="Summer",col='blue')
           text(x=38+2,y=0.9*max(effort),lab="Fall",col='blue')
           text(x=51+2,y=0.9*max(effort),lab="Winter",col='blue')
           abline(v=12,col='blue')
           abline(v=25,col='blue')
           abline(v=38,col='blue')
           abline(v=51,col='blue')
           }
         else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(effort),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(effort),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(effort),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(effort),lab="Wn",col='blue')
           }
         }
       else
         {
         if(tstep=="day")
           {
           text(x=079+10,y=0.9*max(effort),lab="Fall",col='blue')
           text(x=171+10,y=0.9*max(effort),lab="Winter",col='blue')
           text(x=263+10,y=0.9*max(effort),lab="Spring",col='blue')
           text(x=354+10,y=0.9*max(effort),lab="Summer",col='blue')
           abline(v=079,col='blue')
           abline(v=171,col='blue')
           abline(v=263,col='blue')
           abline(v=354,col='blue')
           }
         else if(tstep=="week")
           {
           text(x=12+2,y=0.9*max(effort),lab="Fall",col='blue')
           text(x=25+2,y=0.9*max(effort),lab="Winter",col='blue')
           text(x=38+2,y=0.9*max(effort),lab="Spring",col='blue')
           text(x=51+2,y=0.9*max(effort),lab="Summer",col='blue')
           abline(v=12,col='blue')
           abline(v=25,col='blue')
           abline(v=38,col='blue')
           abline(v=51,col='blue')
           }
         else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(effort),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(effort),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(effort),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(effort),lab="Wn",col='blue')
           }
         }
       plot(x=period,y=catch,main="",xlab=gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", tstep, perl=TRUE),ylab=paste("Catch (",x$Properties$Units[4],")",sep=""),axes=FALSE, pch=19)
       if(mark==TRUE)
         {
          text(x=period,y=catch+max(catch)/offset[2],labels=period)
         } 
       axis(side=1,at=seq(head(period,1),tail(period,1),1))
       axis(side=2,at=NULL)
       if(hem=="N")
         {
          if(tstep=="day")
            {
            text(x=079+10,y=0.9*max(catch),lab="Spring",col='blue')
            text(x=171+10,y=0.9*max(catch),lab="Summer",col='blue')
            text(x=263+10,y=0.9*max(catch),lab="Fall",col='blue')
            text(x=354+10,y=0.9*max(catch),lab="Winter",col='blue')
            abline(v=079,col='blue')
            abline(v=171,col='blue')
            abline(v=263,col='blue')
            abline(v=354,col='blue')
            }
          else if(tstep=="week")
            {
            text(x=12+2,y=0.9*max(catch),lab="Spring",col='blue')
            text(x=25+2,y=0.9*max(catch),lab="Summer",col='blue')
            text(x=38+2,y=0.9*max(catch),lab="Fall",col='blue')
            text(x=51+2,y=0.9*max(catch),lab="Winter",col='blue')
            abline(v=12,col='blue')
            abline(v=25,col='blue')
            abline(v=38,col='blue')
            abline(v=51,col='blue')
            }
          else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(catch),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(catch),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(catch),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(catch),lab="Wn",col='blue')
           }
         }
       else
         {
         if(tstep=="day")
           {
           text(x=079+10,y=0.9*max(catch),lab="Fall",col='blue')
           text(x=171+10,y=0.9*max(catch),lab="Winter",col='blue')
           text(x=263+10,y=0.9*max(catch),lab="Spring",col='blue')
           text(x=354+10,y=0.9*max(catch),lab="Summer",col='blue')
           abline(v=079,col='blue')
           abline(v=171,col='blue')
           abline(v=263,col='blue')
           abline(v=354,col='blue')
           }
         else if(tstep=="week")
           {
           text(x=12+2,y=0.9*max(catch),lab="Fall",col='blue')
           text(x=25+2,y=0.9*max(catch),lab="Winter",col='blue')
           text(x=38+2,y=0.9*max(catch),lab="Spring",col='blue')
           text(x=51+2,y=0.9*max(catch),lab="Summer",col='blue')
           abline(v=12,col='blue')
           abline(v=25,col='blue')
           abline(v=38,col='blue')
           abline(v=51,col='blue')
           }
         else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(catch),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(catch),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(catch),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(catch),lab="Wn",col='blue')
           }
          }
       plot(x=period,y=spike,main="",xlab=gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", tstep, perl=TRUE),ylab="Catch Spike",axes=FALSE, pch=19)
       if(mark==TRUE)
         {
          text(x=period,y=spike+max(spike)/offset[3],labels=period)
         } 
       axis(side=1,at=seq(head(period,1),tail(period,1),1))
       axis(side=2,at=NULL)
       abline(h=0)
       if(hem=="N")
         {
          if(tstep=="day")
            {
            text(x=079+10,y=0.9*max(spike),lab="Spring",col='blue')
            text(x=171+10,y=0.9*max(spike),lab="Summer",col='blue')
            text(x=263+10,y=0.9*max(spike),lab="Fall",col='blue')
            text(x=354+10,y=0.9*max(spike),lab="Winter",col='blue')
            abline(v=079,col='blue')
            abline(v=171,col='blue')
            abline(v=263,col='blue')
            abline(v=354,col='blue')
            }
          else if(tstep=="week")
            {
            text(x=12+2,y=0.9*max(spike),lab="Spring",col='blue')
            text(x=25+2,y=0.9*max(spike),lab="Summer",col='blue')
            text(x=38+2,y=0.9*max(spike),lab="Fall",col='blue')
            text(x=51+2,y=0.9*max(spike),lab="Winter",col='blue')
            abline(v=12,col='blue')
            abline(v=25,col='blue')
            abline(v=38,col='blue')
            abline(v=51,col='blue')
            }
          else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(spike),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(spike),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(spike),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(spike),lab="Wn",col='blue')
           }
         }
       else
         {
         if(tstep=="day")
           {
           text(x=079+10,y=0.9*max(spike),lab="Fall",col='blue')
           text(x=171+10,y=0.9*max(spike),lab="Winter",col='blue')
           text(x=263+10,y=0.9*max(spike),lab="Spring",col='blue')
           text(x=354+10,y=0.9*max(spike),lab="Summer",col='blue')
           abline(v=079,col='blue')
           abline(v=171,col='blue')
           abline(v=263,col='blue')
           abline(v=354,col='blue')
           }
         else if(tstep=="week")
           {
           text(x=12+2,y=0.9*max(spike),lab="Fall",col='blue')
           text(x=25+2,y=0.9*max(spike),lab="Winter",col='blue')
           text(x=38+2,y=0.9*max(spike),lab="Spring",col='blue')
           text(x=51+2,y=0.9*max(spike),lab="Summer",col='blue')
           abline(v=12,col='blue')
           abline(v=25,col='blue')
           abline(v=38,col='blue')
           abline(v=51,col='blue')
           }
         else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(spike),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(spike),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(spike),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(spike),lab="Wn",col='blue')
           }
         }
       plot(x=period,y=mbw,xlab=gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", tstep, perl=TRUE),ylab=paste("Mean Body Mass (",x$Properties$Units[3],")",sep=""),axes=FALSE, pch=19)
       axis(side=1,at=seq(head(period,1),tail(period,1),1))
       axis(side=2,at=NULL)
       if(hem=="N")
         {
          if(tstep=="day")
            {
            text(x=079+10,y=0.9*max(mbw),lab="Spring",col='blue')
            text(x=171+10,y=0.9*max(mbw),lab="Summer",col='blue')
            text(x=263+10,y=0.9*max(mbw),lab="Fall",col='blue')
            text(x=354+10,y=0.9*max(mbw),lab="Winter",col='blue')
            abline(v=079,col='blue')
            abline(v=171,col='blue')
            abline(v=263,col='blue')
            abline(v=354,col='blue')
            }
          else if(tstep=="week")
            {
            text(x=12+2,y=0.9*max(mbw),lab="Spring",col='blue')
            text(x=25+2,y=0.9*max(mbw),lab="Summer",col='blue')
            text(x=38+2,y=0.9*max(mbw),lab="Fall",col='blue')
            text(x=51+2,y=0.9*max(mbw),lab="Winter",col='blue')
            abline(v=12,col='blue')
            abline(v=25,col='blue')
            abline(v=38,col='blue')
            abline(v=51,col='blue')
            }
          else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(mbw),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(mbw),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(mbw),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(mbw),lab="Wn",col='blue')
           }
         }
       else
         {
         if(tstep=="day")
           {
           text(x=079+10,y=0.9*max(mbw),lab="Fall",col='blue')
           text(x=171+10,y=0.9*max(mbw),lab="Winter",col='blue')
           text(x=263+10,y=0.9*max(mbw),lab="Spring",col='blue')
           text(x=354+10,y=0.9*max(mbw),lab="Summer",col='blue')
           abline(v=079,col='blue')
           abline(v=171,col='blue')
           abline(v=263,col='blue')
           abline(v=354,col='blue')
           }
         else if(tstep=="week")
           {
           text(x=12+2,y=0.9*max(mbw),lab="Fall",col='blue')
           text(x=25+2,y=0.9*max(mbw),lab="Winter",col='blue')
           text(x=38+2,y=0.9*max(mbw),lab="Spring",col='blue')
           text(x=51+2,y=0.9*max(mbw),lab="Summer",col='blue')
           abline(v=12,col='blue')
           abline(v=25,col='blue')
           abline(v=38,col='blue')
           abline(v=51,col='blue')
           }
         else
           {
           text(x=seq(4,tail(period,1),12),y=0.9*max(mbw),lab="Sp",col='blue')
           text(x=seq(7,tail(period,1),12),y=0.9*max(mbw),lab="Sm",col='blue')
           text(x=seq(10,tail(period,1),12),y=0.9*max(mbw),lab="Fl",col='blue')
           text(x=seq(1,tail(period,1),12),y=0.9*max(mbw),lab="Wn",col='blue')
           }
         }
       mtext(side=3,outer=TRUE,text=x$Properties$Fleets$Fleet[i])
       devAskNewPage(ask=TRUE)
       }
    devAskNewPage(ask=FALSE)
    }
