suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
})


get_data <- function(n) {
    sigma <- as_vcov(c(2, 1, 0.7), c(0.5, 0.3, 0.2))

    set.seed(1518)

    dat <- get_sim_data(n, sigma, trt = 8) %>%
        mutate(is_miss = rbinom(n(), 1, 0.5)) %>%
        mutate(outcome = if_else(is_miss == 1 & visit == "visit_3", NA_real_, outcome)) %>%
        select(-is_miss) %>%
        mutate(group = factor(group, labels = c("Placebo", "TRT")))


    dat_ice <- dat %>%
        group_by(id) %>%
        arrange(id, visit) %>%
        filter(is.na(outcome)) %>%
        slice(1) %>%
        ungroup() %>%
        select(id, visit) %>%
        mutate(strategy = "JR")


    vars <- set_vars(
        outcome = "outcome",
        group = "group",
        strategy = "strategy",
        subjid = "id",
        visit = "visit",
        covariates = c("age", "sex", "visit * group")
    )
    list(dat = dat, dat_ice = dat_ice, vars = vars)
}





test_that("print - Approx Bayes", {

    dobj <- get_data(100)
    set.seed(3123)

    drawobj_ab <- draws(
        data = dobj$dat,
        data_ice = dobj$dat_ice,
        vars = dobj$vars,
        method = method_approxbayes(
            n_samples = 5,
            threshold = 0.5,
            same_cov = TRUE,
            REML = TRUE,
            covariance = "us"
        )
    )
    expect_snapshot(print(drawobj_ab), cran = TRUE)


    impute_ab <- impute(
        drawobj_ab,
        references = c("TRT" = "Placebo", "Placebo" = "Placebo"),
    )
    expect_snapshot(print(impute_ab), cran = TRUE)


    v2 <- dobj$vars
    v2$covariates <- c("sex*age")
    analysis_ab <- analyse(
        impute_ab,
        fun = ancova,
        vars = v2
    )
    expect_snapshot(print(analysis_ab), cran = TRUE)


    pool_ab <- pool(analysis_ab, conf.level = 0.9, alternative = "less")
    expect_snapshot(print(pool_ab), cran = TRUE)
})





test_that("print - Bayes", {

    # Stan seed is not reproducible across different OS's
    skip_if_not(is_nightly())  

    dobj <- get_data(100)
    set.seed(413)

    suppressWarnings({
        drawobj_b <- draws(
            data = dobj$dat,
            data_ice = dobj$dat_ice,
            vars = dobj$vars,
            method = method_bayes(
                n_samples = 11,
                burn_between = 2,
                verbose = FALSE,
                seed = 859
            )
        )
    })
    expect_snapshot(print(drawobj_b), cran = TRUE)


    impute_b <- impute(
        drawobj_b,
        references = c("TRT" = "TRT", "Placebo" = "Placebo"),
    )
    expect_snapshot(print(impute_b), cran = TRUE)


    v2 <- dobj$vars
    v2$covariates <- c("sex*age")
    analysis_b <- analyse(
        impute_b,
        fun = rbmi::ancova,
        delta = delta_template(impute_b),
        visits = c("visit_1", "visit_3"),
        vars = v2
    )
    expect_snapshot(print(analysis_b), cran = TRUE)


    pool_b <- pool(analysis_b)
    expect_snapshot(print(pool_b), cran = TRUE)
})




test_that("print - condmean (bootstrap)", {
    dobj <- get_data(89)
    set.seed(313)

    drawobj_cmb <- draws(
        data = dobj$dat,
        data_ice = dobj$dat_ice,
        vars = dobj$vars,
        method = method_condmean(
            n_samples = 6,
            threshold = 0.2,
            type = "bootstrap",
            same_cov = TRUE,
            REML = TRUE,
            covariance = "ar1"
        )
    )
    expect_snapshot(print(drawobj_cmb), cran = TRUE)


    impute_cmb <- impute(
        drawobj_cmb,
        references = c("TRT" = "Placebo", "Placebo" = "Placebo"),
    )
    expect_snapshot(print(impute_cmb), cran = TRUE)


    v2 <- dobj$vars
    v2$covariates <- c("sex")
    analysis_cmb <- analyse(
        impute_cmb,
        fun = ancova,
        vars = v2
    )
    expect_snapshot(print(analysis_cmb), cran = TRUE)


    pool_cmb_p <- pool(analysis_cmb, alternative = "greater")
    expect_snapshot(print(pool_cmb_p), cran = TRUE)

    pool_cmb_n <- pool(analysis_cmb, alternative = "greater", type = "normal")
    expect_snapshot(print(pool_cmb_n), cran = TRUE)
})




test_that("print - Condmean (jackknife)", {

    dobj <- get_data(35)
    set.seed(89513)

    drawobj_cmj <- draws(
        data = dobj$dat,
        data_ice = dobj$dat_ice,
        vars = dobj$vars,
        method = method_condmean(
            threshold = 0.5,
            same_cov = FALSE,
            REML = TRUE,
            type = "jackknife",
            covariance = "us"
        )
    )
    expect_snapshot(print(drawobj_cmj), cran = TRUE)

    impute_cmj <- impute(
        drawobj_cmj,
        references = c("TRT" = "Placebo", "Placebo" = "Placebo"),
    )
    expect_snapshot(print(impute_cmj), cran = TRUE)


    v2 <- dobj$vars
    v2$covariates <- c("sex*age")
    analysis_cmj <- analyse(
        impute_cmj,
        fun = ancova,
        vars = v2
    )
    expect_snapshot(print(analysis_cmj), cran = TRUE)


    pool_cmj <- pool(analysis_cmj, conf.level = 0.9)
    expect_snapshot(print(pool_cmj), cran = TRUE)
})
