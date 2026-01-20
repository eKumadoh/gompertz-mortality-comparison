# Gompertz Lifetime Distribution (Code Implementation)

## Overview

This repository contains an **independent computational implementation** of the **Gompertz lifetime distribution**, a classical parametric model widely used in **survival analysis, demography, actuarial science, and reliability theory**.

⚠️ **Important note:**  
The Gompertz distribution implemented here is **not an original contribution** of the repository author.  
This project **only provides code-level implementation** of well-established methods described in the literature.

No theoretical or methodological claims are made.

---

## Model Description

The Gompertz distribution is characterized by a hazard function of the form:

\[
h(x) = \lambda e^{\gamma x}, \quad x > 0,\; \lambda > 0,\; \gamma > 0
\]

The implementation includes:
- Probability density function (PDF)
- Cumulative distribution function (CDF)
- Survival function
- Hazard function

The model is particularly suitable for **monotonically increasing hazard rates**, commonly observed in aging and mortality studies.

---

## Scope of Implementation

This repository focuses strictly on **numerical and computational aspects**, including:

### 1. Random Variate Generation
- Inverse transform sampling
- Simulation of survival times under the Gompertz model

### 2. Likelihood-Based Estimation
- Log-likelihood for complete data
- Log-likelihood for right-censored data
- Maximum Likelihood Estimation (MLE)
- Numerical optimization and convergence checks
- Standard error estimation using the observed information matrix

### 3. Simulation Studies
- Monte Carlo simulation framework
- Performance metrics:
  - Bias
  - Mean Squared Error (MSE)
  - Coverage Probability

> Simulation outputs and numerical summaries are not stored in the repository.

### 4. Application Code
- Fitting the Gompertz model to real lifetime datasets
- Survival and hazard curve visualization
- Comparison with alternative parametric models

---
# Polynomial Hazard Lifetime Model (Code Implementation)

## Overview

This repository contains an **implementation of polynomial-based hazard models** for lifetime and survival data analysis.

⚠️ **Important note:**  
The polynomial hazard model implemented here is **not proposed by the repository author**.  
This repository focuses solely on **coding, estimation, and simulation** of existing polynomial hazard formulations described in the survival analysis literature.

---

## Model Description

Polynomial hazard models define the hazard function as a polynomial function of time:

\[
h(x) = \sum_{k=0}^{p} \alpha_k x^k, \quad x > 0
\]

subject to parameter constraints ensuring non-negativity of the hazard.

This formulation allows for **highly flexible hazard shapes**, including:
- Increasing
- Decreasing
- Bathtub-shaped
- Unimodal patterns

---

## Scope of Implementation

The repository provides code for:

### 1. Hazard and Survival Construction
- Polynomial hazard specification
- Numerical integration for survival and cumulative hazard functions
- Stability checks for admissible parameter values

### 2. Likelihood-Based Inference
- Log-likelihood functions for:
  - Complete data
  - Right-censored data
- Maximum Likelihood Estimation (MLE)
- Constrained optimization routines
- Variance estimation

### 3. Simulation Framework
- Data generation under polynomial hazard specifications
- Monte Carlo experiments
- Evaluation of estimator performance

> Simulation results and tables are intentionally excluded.

### 4. Applications
- Fitting polynomial hazard models to lifetime datasets
- Visual comparison with standard parametric models
- Sensitivity analysis with respect to polynomial order

---


---

## Reproducibility

- All procedures are fully scripted
- Results are reproducible given identical data and seeds
- Code is modular and easy to extend

---

## Intended Use

This repository is intended for:
- Replication and validation studies
- Educational purposes in survival analysis
- Benchmarking against more flexible lifetime models

---

## Citation

Please cite standard references on the Gompertz distribution when using this code for academic work.

---

## Disclaimer

The author of this repository **does not claim authorship** of the Gompertz distribution or its theory.  
All theoretical credit belongs to the original contributors.

