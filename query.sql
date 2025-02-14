WITH datos AS (
    SELECT
        -- Calcula X (sum(purchase_donation_amount_usd)) y Y (count(checkout_vent_id)) para cada observación
        SUM(purchase_donation_amount_usd) AS X,
        COUNT(checkout_vent_id) AS Y
    FROM
        tu_tabla
    GROUP BY
        -- Agrupa por la clave única de cada observación (por ejemplo, user_id, fecha, etc.)
        user_id
),
estadisticas AS (
    SELECT
        AVG(X) AS mu_X,          -- Media de X
        AVG(Y) AS mu_Y,          -- Media de Y
        VARIANCE(X) AS var_X,    -- Varianza de X
        VARIANCE(Y) AS var_Y,    -- Varianza de Y
        COVAR_POP(X, Y) AS cov_XY -- Covarianza entre X e Y
    FROM
        datos
)
SELECT
    -- Calcula la varianza de la ratio (Var(R))
    (var_X / POWER(mu_Y, 2)) 
    + (POWER(mu_X, 2) * var_Y / POWER(mu_Y, 4)) 
    - (2 * mu_X * cov_XY / POWER(mu_Y, 3)) AS var_R,
    
    -- Calcula el desvío estándar de la ratio (std(R))
    SQRT(
        (var_X / POWER(mu_Y, 2)) 
        + (POWER(mu_X, 2) * var_Y / POWER(mu_Y, 4)) 
        - (2 * mu_X * cov_XY / POWER(mu_Y, 3))
    ) AS std_R
FROM
    estadisticas;