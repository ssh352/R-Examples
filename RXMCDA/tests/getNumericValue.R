library(RXMCDA)

tree = newXMLDoc()

newXMLNode("xmcda:XMCDA", namespace = c("xsi" = "http://www.w3.org/2001/XMLSchema-instance", "xmcda" = "http://www.decision-deck.org/2009/XMCDA-2.0.0"), parent=tree)

root<-getNodeSet(tree, "/xmcda:XMCDA")

val<-newXMLNode("value", parent=root[[1]], namespace=c())

newXMLNode("real",3.14,parent=val, namespace=c())

y<-getNodeSet(tree,"//value")

stopifnot(getNumericValue(y) == 3.14)



