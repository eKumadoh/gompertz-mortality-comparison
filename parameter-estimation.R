library(tidyverse)
library(purrr)
library(knitr)
library(broom)

files <- list.files("Survival Analysis", pattern = "\\.csv$", full.names = T)

countries <- c("Argentina", "Brazil", "Canada","China", "France", "Ghana",
               "India", "Mexico", "South Africa","Spain", "United Kingdom",
               "United States", "Venezuela")

df <- map(files, ~read_csv(.x, skip = 1)) |>  
  set_names(countries)

#"ex - expectation of life at age x"
#"lx - number of people left alive at age x"
#"ndx - number of people dying between ages x and x+n"
#"nLx - person-years lived between ages x and x+n"
#"nMx - age-specific death rate between ages x and x+n"
#"nqx - probability of dying between ages x and x+n"
#"Tx - person-years lived above age x"

daTa <- \(x){
  df_2019 <- x |> 
    select(1:3) |> 
    mutate(Indicator = str_replace(Indicator, "\\s-.*", "")) |> 
    janitor::clean_names() |> 
    rename("both_sexes" = both_sexes_3) |> 
    pivot_wider(names_from = indicator, values_from = both_sexes) |> 
    mutate(age_group = ifelse(age_group == "&lt;1 year", "< 1 year", age_group)) |> 
    mutate(age_group = as.character(age_group)) |> 
    mutate(
      lower = case_when(
        grepl("^< *1", age_group) ~ 0,
        grepl("\\+", age_group)   ~ parse_number(age_group),
        TRUE ~ parse_number(sub("-.*", "", age_group))
      ),
      upper = case_when(
        grepl("^< *1", age_group) ~ 1,
        grepl("\\+", age_group)   ~ parse_number(age_group) + 5,  # cap open-ended interval
        TRUE ~ parse_number(sub(".*-", "", age_group)) + 1
      ),
      age_mid = (lower + upper) / 2) 
}

argentina <- daTa(df$Argentina) 
brazil <- daTa(df$Brazil)
canada <- daTa(df$Canada)
china <- daTa(df$China)
france <- daTa(df$France)
ghana <- daTa(df$Ghana)
india <- daTa(df$India)
mexico <- daTa(df$Mexico)
south_africa <- daTa(df$`South Africa`)
spain <- daTa(df$Spain)
uk <- daTa(df$`United Kingdom`)
us <- daTa(df$`United States`)
venezuela <- daTa(df$Venezuela)

#Gompertz model
gompertz_fit <- \(country){
  fit = nls(nMx ~ alpha * exp(beta * age_mid),
            data = {country} |> filter(lower >= 30),
            start = list(alpha = 1e-4, beta = 0.08),
            control = nls.control(maxiter = 500, warnOnly = TRUE))
  
  tidy(fit) |> 
    mutate(estimate = round(estimate, 10),
           p.value = round(p.value, 4),
           p.value = ifelse(p.value < 0.001, "< 0.001", p.value)) |> 
    kable(caption = "Gompertz Model")
}

#Polynomial model
poly_fit <- \(country){
  fit = lm(nMx ~ poly(age_mid, 6),
           data = {country} |> filter(lower >= 30))
  
  tidy(fit) |> 
    mutate(p.value = round(p.value, 4),
           p.value = ifelse(p.value < 0.001, "< 0.001", p.value)) |> 
    kable(caption = "Polynomial Model(Order 6)")
}

#Mortality Curve
nMx_plot <- \(country){
  gompertz_fit = nls(nMx ~ alpha * exp(beta * age_mid),
                     data = {country} |> filter(lower >= 30),
                     start = list(alpha = 1e-4, beta = 0.08),
                     control = nls.control(maxiter = 500, 
                                           warnOnly = TRUE))
  
  poly_fit = lm(nMx ~ poly(age_mid, 6),
                data = {country} |> filter(lower >= 30))
  
  {country} |>
    filter(lower >= 30)|>
    mutate(
      gompertz_pred = predict(gompertz_fit, newdata = {country} |>
                                filter(lower >= 30)),
      poly_pred = predict(poly_fit, newdata = {country} |>
                            filter(lower >= 30))
    ) |>
    ggplot(aes(x = age_mid, y = nMx)) +
    geom_point(color = "black", size = 2) +  # observed data
    geom_line(aes(y = gompertz_pred, color = "Gompertz"), size = 1) +
    geom_line(aes(y = poly_pred, color = "Polynomial (6th order)"), size = 1, linetype = "dashed") +
    labs(
      title = "Comparison of Gompertz vs 6th-order Polynomial \n Model",
      x = "Age (midpoint of interval)",
      y = "Mortality rate (nMx)",
      color = "Model"
    ) +
    theme_minimal(base_size = 14)
}

#Goodness of Fit
gof <- \(country){
  gompertz_fit = nls(nMx ~ alpha * exp(beta * age_mid),
                     data = {country} |> filter(lower >= 30),
                     start = list(alpha = 1e-4, beta = 0.08),
                     control = nls.control(maxiter = 500,
                                           warnOnly = TRUE))
  
  poly_fit = lm(nMx ~ poly(age_mid, 6),
                data = {country} |> filter(lower >= 30))
  
  tibble(Model = c("Gompertz", "Polynomial (6th rder)"),
         `2 x logLik` = c(2*logLik(gompertz_fit),
                          2*logLik(poly_fit)),
         AIC = c(AIC(gompertz_fit), AIC(poly_fit)),
         `Residual Error` = c(summary(gompertz_fit)$sigma,
                              summary(poly_fit)$sigma)) |>
    kable(caption = "Model Comparison")
}

#Probabilities
compare_probs <- \(country){
  gompertz_fit <- nls(nMx ~ alpha * exp(beta * age_mid),
                      data = country |> filter(lower >= 30),
                      start = list(alpha = 1e-4, beta = 0.08),
                      control = nls.control(maxiter = 500, warnOnly = TRUE))
  
  poly_fit <- lm(nMx ~ poly(age_mid, 6),
                 data = country |> filter(lower >= 30))
  
  df <- country |> filter(lower >= 30) |>
    mutate(
      gompertz_nMx = predict(gompertz_fit, newdata = country |> filter(lower >= 30)),
      poly_nMx = predict(poly_fit, newdata = country |> filter(lower >= 30)),
      
      qx_obs  = nqx,
      px_obs  = 1 - nqx,
      
      qx_gomp = gompertz_nMx / (1 + 0.5 * gompertz_nMx),
      px_gomp = 1 - qx_gomp,
      
      qx_poly = poly_nMx / (1 + 0.5 * poly_nMx),
      px_poly = 1 - qx_poly
    ) |>
    select(age_group, nMx, gompertz_nMx, poly_nMx,
           qx_obs, qx_gomp, qx_poly,
           px_obs, px_gomp, px_poly)
  
  df |> 
    mutate(across(-age_group, ~round(.x, 6))) |> 
    kable(caption = "Observed vs Predicted Mortality and Survival (Gompertz vs Polynomial)")
}

## Argentina
gompertz_fit(argentina)

poly_fit(argentina)

nMx_plot(argentina)

gof(argentina)

compare_probs(argentina)


## Brazil
gompertz_fit(brazil)

poly_fit(brazil)

nMx_plot(brazil)

gof(brazil)

compare_probs(brazil)

## Canada
gompertz_fit(canada)

poly_fit(canada)

nMx_plot(canada)

gof(canada)

compare_probs(canada)

## China
gompertz_fit(china)

poly_fit(china)

nMx_plot(china)

gof(china)

compare_probs(china)

## France
gompertz_fit(france)

poly_fit(france)

nMx_plot(france)

gof(france)

compare_probs(france)

## Ghana
gompertz_fit(ghana)

poly_fit(ghana)

nMx_plot(ghana)

gof(ghana)

compare_probs(ghana)

## India
gompertz_fit(india)

poly_fit(india)

nMx_plot(india)

gof(india)

compare_probs(india)

## Mexico
gompertz_fit(mexico)

poly_fit(mexico)

nMx_plot(mexico)

gof(mexico)

compare_probs(mexico)

## South Africa
gompertz_fit(south_africa)

poly_fit(south_africa)

nMx_plot(south_africa)

gof(south_africa)

compare_probs(south_africa)

## Spain
gompertz_fit(spain)

poly_fit(spain)

nMx_plot(spain)

gof(spain)

compare_probs(spain)

## UK
gompertz_fit(uk)

poly_fit(uk)

nMx_plot(uk)

gof(uk)

compare_probs(uk)

## US
gompertz_fit(us)

poly_fit(us)

nMx_plot(us)

gof(us)

compare_probs(us)

## Venezuela
gompertz_fit(venezuela)

poly_fit(venezuela)

nMx_plot(venezuela)

gof(venezuela)

compare_probs(venezuela)

