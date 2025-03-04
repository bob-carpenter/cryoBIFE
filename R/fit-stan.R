## Run from the directory in which this file resides.
## > source('fit.R')
## > plot

library("cmdstanr")
library("rstan")
library("ggplot2")

options(width=150)
options(cmdstanr_max_rows=1e3)

Pmat <- read.csv("../data/Pmat.tsv", sep="\t")
N <- dim(Pmat)[1]
M <- dim(Pmat)[2]
data <- list(M = M, N = N, Pmat = Pmat)

mod <- cmdstan_model("../stan/cryo-bife.stan")
fit <- mod$sample(data = data, chains = 4, parallel_chains = 4)

mod_marginal <- cmdstan_model("../stan/cryo-bife-marginal.stan")
fit_marginal <- mod_marginal$sample(data = data, chains = 4, parallel_chains = 4)

print(fit, c("rho", "lambda"))
print(fit_marginal, c("rho"))

### plot posterior simplex estimate
rho_hat <- fit$summary("rho", mean)$mean
df <- data.frame(node = 1:M, prob = rho_hat)
plot <-
    ggplot(df, aes(x = node, y = prob)) +
    scale_y_continuous(lim = c(0, max(rho_hat) + 0.01)) +
    geom_line()
ggsave("node-vs-prob.pdf", plot)




