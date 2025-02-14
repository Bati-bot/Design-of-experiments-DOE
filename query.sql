WITH datos AS (
    SELECT
        fundraiser_country_iso,  -- Agrupa por país
        SUM(purchase_donation_amount_usd) AS X,  -- Suma de montos por país
        COUNT(checkout_vent_id) AS Y             -- Conteo de checkouts por país
    FROM
        tu_tabla
    GROUP BY
        fundraiser_country_iso  -- Agrupa por país
),
ratios AS (
    SELECT
        fundraiser_country_iso,
        X / Y AS ratio  -- Calcula la ratio X/Y para cada país
    FROM
        datos
),
estadisticas AS (
    SELECT
        fundraiser_country_iso,
        AVG(X) AS mu_X,          -- Media de X por país
        AVG(Y) AS mu_Y,          -- Media de Y por país
        VARIANCE(X) AS var_X,    -- Varianza de X por país
        VARIANCE(Y) AS var_Y,    -- Varianza de Y por país
        COVAR_POP(X, Y) AS cov_XY, -- Covarianza entre X e Y por país
        AVG(ratio) AS media_ratio -- Media de la ratio X/Y por país
    FROM
        datos
    JOIN
        ratios ON datos.fundraiser_country_iso = ratios.fundraiser_country_iso
    GROUP BY
        fundraiser_country_iso  -- Agrupa por país
)
SELECT
    fundraiser_country_iso,
    media_ratio,  -- Media de la ratio X/Y por país
    -- Calcula la varianza de la ratio (Var(R)) por país
    (var_X / POWER(mu_Y, 2)) 
    + (POWER(mu_X, 2) * var_Y / POWER(mu_Y, 4)) 
    - (2 * mu_X * cov_XY / POWER(mu_Y, 3)) AS var_R,
    
    -- Calcula el desvío estándar de la ratio (std(R)) por país
    SQRT(
        (var_X / POWER(mu_Y, 2)) 
        + (POWER(mu_X, 2) * var_Y / POWER(mu_Y, 4)) 
        - (2 * mu_X * cov_XY / POWER(mu_Y, 3))
    ) AS std_R
FROM
    estadisticas;