-- 1. Rule-based risk segmentation
SELECT
    udi,
    product_id,
    type,
    torque_nm,
    rotational_speed_rpm,
    tool_wear_min,
    machine_failure,
    CASE
        WHEN tool_wear_min >= 200 AND torque_nm >= 50 THEN 'High risk'
        WHEN tool_wear_min >= 150 OR torque_nm >= 45 THEN 'Medium risk'
        ELSE 'Low risk'
    END AS risk_segment
FROM machine_readings
ORDER BY
    CASE
        WHEN tool_wear_min >= 200 AND torque_nm >= 50 THEN 1
        WHEN tool_wear_min >= 150 OR torque_nm >= 45 THEN 2
        ELSE 3
    END,
    tool_wear_min DESC,
    torque_nm DESC;


-- 2. Failure rate by risk segment
WITH risk_data AS (
    SELECT
        *,
        CASE
            WHEN tool_wear_min >= 200 AND torque_nm >= 50 THEN 'High risk'
            WHEN tool_wear_min >= 150 OR torque_nm >= 45 THEN 'Medium risk'
            ELSE 'Low risk'
        END AS risk_segment
    FROM machine_readings
)

SELECT
    risk_segment,
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM risk_data
GROUP BY risk_segment
ORDER BY failure_rate_pct DESC;


-- 3. Top 20 highest-risk records
SELECT
    udi,
    product_id,
    type,
    air_temperature_k,
    process_temperature_k,
    rotational_speed_rpm,
    torque_nm,
    tool_wear_min,
    machine_failure,
    ROUND(
        (tool_wear_min * 0.4) +
        (torque_nm * 2.0) -
        (rotational_speed_rpm * 0.02),
        2
    ) AS simple_risk_score
FROM machine_readings
ORDER BY simple_risk_score DESC
LIMIT 20;


-- 4. Risk score average by product type
SELECT
    type,
    COUNT(*) AS total_records,
    ROUND(AVG(
        (tool_wear_min * 0.4) +
        (torque_nm * 2.0) -
        (rotational_speed_rpm * 0.02)
    ), 2) AS avg_simple_risk_score,
    SUM(machine_failure) AS total_failures
FROM machine_readings
GROUP BY type
ORDER BY avg_simple_risk_score DESC;


-- 5. Operating condition buckets
SELECT
    CASE
        WHEN rotational_speed_rpm < 1300 THEN 'Low RPM'
        WHEN rotational_speed_rpm < 1700 THEN 'Normal RPM'
        ELSE 'High RPM'
    END AS rpm_bucket,
    CASE
        WHEN torque_nm < 35 THEN 'Low torque'
        WHEN torque_nm < 55 THEN 'Normal torque'
        ELSE 'High torque'
    END AS torque_bucket,
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM machine_readings
GROUP BY rpm_bucket, torque_bucket
ORDER BY failure_rate_pct DESC;