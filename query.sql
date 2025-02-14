WITH datos AS (
    SELECT
        fundraiser_country_iso,  -- Agrupa por país
        purchase_donation_amount_usd AS X,  -- Monto de la compra/donación
        CASE 
            WHEN checkout_vent_id IS NOT NULL THEN 1 
            ELSE 0 
        END AS Y  -- Indicador de checkout (1 si hay checkout, 0 si no)
    FROM
        tu_tabla
),
ratios AS (
    SELECT
        fundraiser_country_iso,
        SUM(X) AS total_X,  -- Suma de montos por país
        SUM(Y) AS total_Y,  -- Conteo de checkouts por país
        SUM(X) / SUM(Y) AS ratio  -- Ratio X/Y para cada país
    FROM
        datos
    GROUP BY
        fundraiser_country_iso
),
covarianza AS (
    SELECT
        fundraiser_country_iso,
        AVG(X * Y) - AVG(X) * AVG(Y) AS cov_XY  -- Covarianza entre X e Y por país
    FROM
        datos
    GROUP BY
        fundraiser_country_iso
),
estadisticas AS (
    SELECT
        ratios.fundraiser_country_iso,
        ratios.total_X / ratios.total_Y AS media_ratio,  -- Media de la ratio X/Y por país
        VARIANCE(datos.X) AS var_X,  -- Varianza de X por país
        VARIANCE(datos.Y) AS var_Y,  -- Varianza de Y por país
        covarianza.cov_XY  -- Covarianza entre X e Y por país
    FROM
        ratios
    JOIN
        datos ON ratios.fundraiser_country_iso = datos.fundraiser_country_iso
    JOIN
        covarianza ON ratios.fundraiser_country_iso = covarianza.fundraiser_country_iso
    GROUP BY
        ratios.fundraiser_country_iso, ratios.total_X, ratios.total_Y, covarianza.cov_XY
)
SELECT
    fundraiser_country_iso,
    media_ratio,  -- Media de la ratio X/Y por país
    -- Calcula la varianza de la ratio (Var(R)) por país
    (var_X / POWER(total_Y, 2)) 
    + (POWER(total_X, 2) * var_Y / POWER(total_Y, 4)) 
    - (2 * total_X * cov_XY / POWER(total_Y, 3)) AS var_R,
    
    -- Calcula el desvío estándar de la ratio (std(R)) por país
    SQRT(
        (var_X / POWER(total_Y, 2)) 
        + (POWER(total_X, 2) * var_Y / POWER(total_Y, 4)) 
        - (2 * total_X * cov_XY / POWER(total_Y, 3))
    ) AS std_R
FROM
    estadisticas;