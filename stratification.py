import numpy as np
from scipy.stats import norm

# Define the data for each stratum
strata = [
    {
        "population": 10000,  # N_h
        "sample": 1000,       # n_h
        "responses": 200,     # Number of responses
        "leaders": 50         # Number of leaders
    },
    {
        "population": 20000,  # N_h
        "sample": 2000,       # n_h
        "responses": 500,     # Number of responses
        "leaders": 100        # Number of leaders
    }
]

# Total population
total_population = sum(stratum["population"] for stratum in strata)

# Calculate the proportion of leaders and variance for each stratum
estimated_proportion = 0
variance = 0

for stratum in strata:
    N_h = stratum["population"]
    n_h = stratum["sample"]
    responses = stratum["responses"]
    leaders = stratum["leaders"]
    
    # Proportion of leaders in the stratum
    p_h = leaders / responses
    
    # Weight for the stratum
    weight = N_h / total_population
    
    # Add to the estimated population proportion
    estimated_proportion += weight * p_h
    
    # Variance contribution from the stratum
    stratum_variance = (weight ** 2) * ((N_h - n_h) / N_h) * (p_h * (1 - p_h)) / (n_h - 1)
    variance += stratum_variance

# Standard error
standard_error = np.sqrt(variance)

# 95% confidence interval
z_value = norm.ppf(0.975)  # 1.96 for 95% confidence
ci_lower = estimated_proportion - z_value * standard_error
ci_upper = estimated_proportion + z_value * standard_error

# Print results
print(f"Estimated proportion of leaders: {estimated_proportion:.4f}")
print(f"95% Confidence Interval: ({ci_lower:.4f}, {ci_upper:.4f})")