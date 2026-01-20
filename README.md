# Cross-Country Mortality Modeling Using Life Table Data
# Overview

This repository contains R code for modeling and comparing adult mortality patterns across multiple countries using life table data.

The project focuses on fitting and evaluating the classical Gompertz mortality model against a flexible high-order polynomial model using age-specific mortality rates. The analysis is applied consistently across several countries to examine similarities and differences in adult mortality dynamics.

📌 Only code is provided. Numerical results and interpretations are intentionally excluded, as further analysis and manuscript preparation are ongoing.

-  Data Description

Input data consist of life table indicators obtained from publicly available demographic sources.

Key variables include:

  - nMx: age-specific mortality rate

  - nqx: probability of dying

  - lx, ndx, nLx, Tx, ex

Analysis focuses on both sexes combined

Adult ages are defined as age ≥ 30 years

⚠️ Raw data files are not redistributed; users are expected to supply compatible CSV inputs.

# Countries Included

The code is structured to analyze the following countries independently:

- Argentina

- Brazil

- Canada

- China

- France

- Ghana

- India

- Mexico

- South Africa

- Spain

- United Kingdom

- United States

- Venezuela

# Mortality Models
- Gompertz Model
- Polynomial Model of Order 6

