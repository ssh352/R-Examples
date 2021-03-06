context('CheckModList')


test_that('CheckModList works.', {
  a <- substitute('mod')
  b <- substitute(mod(para='pm'))
  c <- substitute(list('mod1', 'mod2'))
  d <- substitute(list(mod1, 'mod2'))
  e <- substitute(list(mod1, mod2))
  f <- substitute(list(mod1(para='pm'), 'mod2'))
  g <- substitute(list(mod1(para='pm'), mod2(para='pm')))
  h <- substitute(list(mod1(para='pm', p2 = 2), mod2(para='pm')))
  i <- substitute(Chain(mod1(para='m', p2 = 2), mod2(para='pm')))
  
  
  # Deal with occurrence = 'module1(k=2)',
  
  testNames <- function(l) names(l) == c('module', 'paras')
  
  expect_true(all(sapply(CheckModList(a), testNames)))
  expect_true(all(sapply(CheckModList(b), testNames)))
  expect_true(all(sapply(CheckModList(c), testNames)))
  expect_true(all(sapply(CheckModList(d), testNames)))     
  expect_true(all(sapply(CheckModList(e), testNames)))
  expect_true(all(sapply(CheckModList(f), testNames)))
  expect_true(all(sapply(CheckModList(g), testNames)))
  expect_true(all(sapply(CheckModList(h), testNames)))
  expect_true(all(sapply(CheckModList(i), testNames)))
  
  expect_equal(length(CheckModList(a)), 1)
  expect_equal(length(CheckModList(b)), 1)
  expect_equal(length(CheckModList(c)), 2)
  expect_equal(length(CheckModList(d)), 2)
  expect_equal(length(CheckModList(e)), 2)	
  expect_equal(length(CheckModList(f)), 2)
  expect_equal(length(CheckModList(g)), 2)
  expect_equal(length(CheckModList(h)), 2)
  
  expect_true(identical(attr(CheckModList(i), 'chain'), TRUE))
  expect_false(identical(attr(CheckModList(a), 'chain'), TRUE))
  expect_false(identical(attr(CheckModList(b), 'chain'), TRUE))
  expect_false(identical(attr(CheckModList(c), 'chain'), TRUE))
  
})