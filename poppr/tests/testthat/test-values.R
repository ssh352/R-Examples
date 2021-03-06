context("Analytical value tests")

test_that("Bruvo's distance works as expected.", {
  testdf  <- data.frame(test = c("00/20/23/24", "20/24/26/43"))
  testgid <- df2genind(testdf, ploidy = 4, sep = "/")
  addloss <- as.vector(bruvo.dist(testgid, add = FALSE, loss = FALSE))
  ADDloss <- as.vector(bruvo.dist(testgid, add = TRUE, loss = FALSE))
  addLOSS <- as.vector(bruvo.dist(testgid, add = FALSE, loss = TRUE))
  ADDLOSS <- as.vector(bruvo.dist(testgid, add = TRUE, loss = TRUE))
  # Values from Bruvo et. al. (2004)
  expect_equal(addloss, 0.46875000000000)
  expect_equal(addLOSS, 0.34374987334013)
  expect_equal(ADDloss, 0.458333164453506)
  expect_equal(ADDLOSS, 0.401041518896818)
})

test_that("Repeat lengths can be in any order and length if named", {
  skip_on_cran()
  data("Pram")
  p10 <- Pram[sample(nInd(Pram), 10)]
  # Repeat length as normal
  pbruvo <- bruvo.dist(p10, replen = other(p10)$REPLEN)
  # Repeat lengths mixed up
  pbruvo_sampled <- bruvo.dist(p10, replen = sample(other(p10)$REPLEN))
  # Extra value in repeat lengths
  pbruvo_long <- bruvo.dist(p10, replen = c(other(p10)$REPLEN, NOPE = 23))
  expect_equivalent(pbruvo, pbruvo_sampled)
  expect_equivalent(pbruvo, pbruvo_long)
})

test_that("Bruvo's distance can be calculated per locus", {
  skip_on_cran()
  data("Pram")
  p10 <- Pram[sample(nInd(Pram), 10)]
  pbruvo <- bruvo.dist(p10, replen = other(p10)$REPLEN, by_locus = TRUE)
  expect_is(pbruvo, "list")
  expect_is(pbruvo[[1]], "dist")
  expect_equal(length(pbruvo), nLoc(p10))
})

test_that("Infinite Alleles Model works.",{
  x <- structure(list(V3 = c("228/236/242", "000/211/226"), 
                      V6 = c("190/210/214", "000/190/203")), 
                 .Names = c("V3", "V6"), row.names = c("1", "2"), 
                 class = "data.frame")
  gid <- df2genind(x, sep = "/", ploidy = 3)
  res <- bruvo.dist(gid, replen = c(2/10000,2/10000), add = FALSE, loss = FALSE)
  expect_equal(as.numeric(res), 0.833333333333333)
})

test_that("Dissimilarity distance works as expected.", {
  data(nancycats, package = "adegenet")
  nan1 <- popsub(nancycats, 1)
  nanmat <- diss.dist(nan1, mat = TRUE)
  expect_that(diss.dist(nan1), is_a("dist"))
  expect_that(nanmat, is_a("matrix"))
  expect_equal(diss.dist(nan1, mat = TRUE, percent = TRUE), (nanmat/2)/9)
  expect_equal(nanmat[2, 1], 4)
})

test_that("Index of association works as expected.", {
  data(Aeut, package = "poppr")
  # Values from Grünwald and Hoheisel (2006)
  res <- c(Ia = 14.3707995986407, rbarD = 0.270617053778004)
  expect_equal(ia(Aeut), res)
})

test_that("Internal function fix_negative_branch works as expected.", {
  the_tree <- structure(list(edge = structure(c(9L, 10L, 11L, 12L, 13L, 14L,
      14L, 13L, 12L, 11L, 10L, 9L, 9L, 10L, 11L, 12L, 13L, 14L, 2L, 3L, 6L, 7L,
      8L, 1L, 5L, 4L), .Dim = c(13L, 2L)), 
      edge.length = c(0, 0.0625, 0.0625, 0.09375, 0.15, -0.25, 0.25, -0.15,
      -0.09375, -0.0625, 0, 0, 0),
      tip.label = c("2340_50156.ab1 ", "2340_50149.ab1 ", "2340_50674.ab1 ",
      "2370_45312.ab1 ", "2340_50406.ab1 ", "2370_45424.ab1 ", "2370_45311.ab1
      ", "2370_45521.ab1 "), 
      Nnode = 6L
    ),
    .Names = c("edge", "edge.length", "tip.label", "Nnode"), 
    class = "phylo",
    order = "cladewise")
  fix_tree <- poppr:::fix_negative_branch(the_tree)
  # Not all branch lengths are positive
  expect_false(min(the_tree$edge.length) >= 0)
  # After fix, all branch lengths are positive
  expect_true(min(fix_tree$edge.length) >= 0)
  # The difference from fixed and unfixed is unfixed. This indicates that the
  # clones were set to zero and the fix set the branch lengths in the correct 
  # order.
  expect_equivalent(min(fix_tree$edge.length - the_tree$edge.length), min(the_tree$edge.length))
})

test_that("mlg.matrix returns a matrix and not table", {
  data(partial_clone)
  mat4row <- poppr:::mlg.matrix(partial_clone)
  pop(partial_clone) <- NULL
  mat1row <- poppr:::mlg.matrix(partial_clone)
  expect_that(mat4row, is_a("matrix"))
  expect_that(mat1row, is_a("matrix"))
  expect_false(inherits(mat1row, "table"))
  expect_false(inherits(mat4row, "table"))
})

test_that("diversity_stats returns expected values", {
  skip_on_cran()
  data("Aeut", package = "poppr")
  expected <- structure(c(4.06272002528149, 3.66843094399907, 4.55798828426928,
  42.1928251121076, 28.7234042553191, 68.9723865877712, 0.976299287915825,
  0.965185185185185, 0.985501444136235, 0.721008688944842, 0.725926650260449,
  0.720112175857993), .Dim = 3:4, .Dimnames = structure(list(Pop = c("Athena",
  "Mt. Vernon", "Total"), Index = c("H", "G", "simp", "E.5")), .Names = c("Pop",
  "Index")))
  
  atab       <- mlg.table(Aeut, plot = FALSE, total = TRUE)
  res        <- diversity_stats(atab)
  pop(Aeut)  <- NULL
  res_single <- diversity_stats(atab["Total", , drop = FALSE])
  
  expect_equivalent(res, expected)
  expect_false(is.matrix(res_single))
  expect_equivalent(res_single, res["Total", ])
})

test_that("get_boot_x works with one pop or one stat", {
  skip_on_cran()
  data(Pinf)
  Ptab <- mlg.table(Pinf, plot = FALSE)
  pop(Pinf) <- NULL
  ptab <- mlg.table(Pinf, plot = FALSE)
  
  Pboot_all <- diversity_ci(Ptab, 20L, plot = FALSE)
  Pboot_E   <- diversity_ci(Ptab, 20L, G = FALSE, H = FALSE, lambda = FALSE, plot = FALSE)
  pboot_all <- diversity_ci(ptab, 20L, plot = FALSE)
  pboot_E   <- diversity_ci(ptab, 20L, G = FALSE, H = FALSE, lambda = FALSE, plot = FALSE)
  
  Past <- poppr:::get_boot_stats(Pboot_all$boot)
  PEst <- poppr:::get_boot_stats(Pboot_E$boot)
  past <- poppr:::get_boot_stats(pboot_all$boot)
  pEst <- poppr:::get_boot_stats(pboot_E$boot)
  
  
  expect_equivalent(dim(Past), c(2, 4))
  expect_equivalent(dim(PEst), c(2, 1))
  expect_equivalent(dim(past), c(1, 4))
  expect_equivalent(dim(pEst), c(1, 1))
  
})

test_that("ia returns NA with less than three samples", {
  skip_on_cran()
  data(partial_clone)
  pc <- partial_clone[sample(50, 2)]
  expect_equivalent(rep(NA_real_, 2), ia(pc))
  expect_equivalent(rep(NA_real_, 4), ia(pc, sample = 9))
})

test_that("ia and pair.ia return same values", {
  skip_on_cran()
  data(partial_clone)
  pc_pair <- pair.ia(partial_clone, plot = FALSE, quiet = TRUE)
  expect_output(print(pc_pair), "Locus_1:Locus_2")
  
  # Randomly sample two loci
  set.seed(9001)
  locpair <- sample(locNames(partial_clone), 2)
  
  # Calculate ia for those
  pc_ia   <- ia(partial_clone[loc = locpair])
  
  # Find the pair in the table
  pair_posi <- grepl(locpair[1], rownames(pc_pair)) & grepl(locpair[2], rownames(pc_pair))

  expect_equivalent(pc_pair[pair_posi], pc_ia)
})


test_that("win.ia produces expected results", {
  skip_on_cran()
  set.seed(999)
  x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, n.snp.struc = 5e2, ploidy = 2)
  position(x) <- sort(sample(1e4, 1e3))
  pos.res <- c(0.0455840455840456, -0.121653107452204, -0.00595292101094314,
               0.0080791417110234, -0.0168361601753453, -0.00529454073927957,
               -0.00897633972053186, -0.0127370947405975, -0.0449102196309011,
               -0.00973722044247706, -0.00395345516884293, -0.00365271629340326,
               -0.00974233012233703, -0.00245476433207628, 0.00284396024347222,
               -0.00961958529835491, 0.0131920863329584, 0.153481745744672,
               0.267842562306642, 0.241714085779086, 0.218062029786597,
               0.160460027459485, 0.351036788453414, 0.165485011482322,
               0.275776270167356, 0.292113177590906, 0.201538950412372,
               0.146277858717017, 0.171243142808176, 0.213214941672605,
               0.200245399275377, 0.243007310007378, 0.12396191060666,
               0.0350644169627312 )

  nopos.res <- c(0.00124186533451839, 0.0334854151956646, 0.226632983481153, 
                 0.173916930910343)

  win.pos     <- win.ia(x, window = 300L, quiet = TRUE)
  position(x) <- NULL
  win.nopos   <- win.ia(x, window = 300L, quiet = TRUE)
  expect_equivalent(win.pos, pos.res)
  expect_equivalent(win.nopos, nopos.res)
  
  # Making sure that the genind version does the same thing.
  xmat <- as.matrix(x)
  xmat[xmat == 0]   <- "1/1"
  xmat[xmat == "1"] <- "1/2"
  xmat[xmat == "2"] <- "2/2"
  xgid <- df2genind(xmat[, 1:300], sep = "/", ind.names = .genlab("", 10), 
                    loc.names = .genlab("", 300L))
  gid.res <- ia(xgid)["rbarD"]
  expect_equivalent(gid.res, nopos.res[1])
})

test_that("win.ia can handle missing data for haploids", {
  skip_on_cran()
  set.seed(999)
  dat <- sample(c(0, 1, NA), 500, replace = TRUE, prob = c(0.47, 0.47, 0.06))
  mat <- matrix(dat, nrow = 5, ncol = 100)
  x   <- new("genlight", mat, parallel = FALSE)
  gid <- df2genind(mat + 1, ind.names = .genlab("", 5), ploidy = 1,
                   loc.names = .genlab("", 100))
  bit.res <- win.ia(x, quiet = TRUE)
  gid.res <- ia(gid)["rbarD"]
  expect_equivalent(bit.res, gid.res)
})

test_that("win.ia can handle missing data for diploids", {
  skip_on_cran()
  set.seed(999)
  dat <- sample(c(0, 1, 2, NA), 500, replace = TRUE, prob = c(0.22, 0.5, 0.22, 0.06))
  mat <- matrix(dat, nrow = 5, ncol = 100)
  x   <- new("genlight", mat, parallel = FALSE)
  mat[mat == 0]   <- "1/1"
  mat[mat == "1"] <- "1/2"
  mat[mat == "2"] <- "2/2"
  gid <- df2genind(mat, ind.names = .genlab("", 5), ploidy = 2, sep = "/",
                   loc.names = .genlab("", 100))
  bit.res <- win.ia(x, quiet = TRUE)
  gid.res <- ia(gid)["rbarD"]
  expect_equivalent(bit.res, gid.res)
})

test_that("win.ia knows the batman theme", {
  skip_on_cran()
  set.seed(999)
  x <- glSim(n.ind = 10, n.snp.nonstruc = 2.5e2, n.snp.struc = 2.5e2, ploidy = 2)
  position(x) <- sort(sample(5e3, 5e2))
  res <- win.ia(x, window = 325L, min.snps = 100L, quiet = TRUE)
  expect_true(all(is.na(res)))
  # NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA
  # BATMAN!
})

test_that("samp.ia works",{
  skip_on_cran()
  set.seed(999)
  x <- glSim(n.ind = 10, n.snp.nonstruc = 5e2, n.snp.struc = 5e2, ploidy = 2)
  position(x) <- sort(sample(1e4, 1e3))
  set.seed(900)
  pos.res <- samp.ia(x, n.snp = 20, reps = 2, quiet = TRUE)
  expect_equivalent(pos.res, c(0.0754028380744677, 0.0178846504949451))

  # Sampling is agnostic to position
  position(x) <- NULL
  set.seed(900)
  nopos.res <- samp.ia(x, n.snp = 20, reps = 2, quiet = TRUE)
  expect_equivalent(nopos.res, pos.res)
})

test_that("fix_replen works as expected", {
  data(nancycats)
  nanrep  <- rep(2, 9)
  nantest <- test_replen(nancycats, nanrep)
  nanfix  <- fix_replen(nancycats, nanrep)
  expect_equal(sum(nantest), 5)
  expect_true(all(floor(nanfix)[!nantest] == 1))
})

test_that("fix_replen throws errors for weird replens", {
  skip_on_cran()
  data(partial_clone)
  expect_warning(fix_replen(partial_clone, rep(10, 10)), paste(locNames(partial_clone), collapse = ", "))
  expect_warning(fix_replen(partial_clone, rep(10, 10), fix_some = FALSE), "Original repeat lengths are being returned")
  expect_warning(fix_replen(partial_clone, rep(2, 10)), "The repeat lengths for Locus_2, Locus_7, Locus_9 are not consistent.")
  expect_warning(fix_replen(partial_clone, rep(2, 10)), "Repeat lengths with some modification are being returned: Locus_3")
})

test_that("poppr_has_parallel returns something logical", {
  expect_is(poppr_has_parallel(), "logical")
})