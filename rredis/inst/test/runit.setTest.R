options('redis:num'=TRUE) # many tests assume : returns numeric

test01_connect <- function()
{
  redisConnect()
  redisFlushDB()
}

test02_redisSAdd_Inter <- function()
{
  redisSAdd("A",1)
  redisSAdd("A",2)
  redisSAdd("A",3)
  redisSAdd("B",2)
  checkEquals(2, redisSInter("A","B")[[1]])
}

test03_redisSUnion <- function()
{
  checkEquals(TRUE, all(list(1,2,3) %in% redisSUnion("A","B")))
}

test04_redisSCard <- function()
{
  checkEquals(3, redisSCard("A"))
}

test05_redisSort <- function()
{
  redisSAdd("sort",charToRaw("x"))
  redisSAdd("sort",charToRaw("y"))
  redisSAdd("sort",charToRaw("z"))
  checkEquals(c("z","y","x"),unlist(redisSort("sort",alpha=TRUE,decreasing=TRUE)))
}
