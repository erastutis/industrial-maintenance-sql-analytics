-- 1. Preview dataset
SELECT *
FROM machine_readings
LIMIT 10;


-- 2. Dataset size
SELECT
    COUNT(*) AS total_records
FROM machine_readings;


-- 3. Overall machine failure rate
SELECT
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM machine_readings;


-- 4. Product type distribution
SELECT
    type,
    COUNT(*) AS total_records,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM machine_readings), 2) AS share_pct
FROM machine_readings
GROUP BY type
ORDER BY total_records DESC;


-- 5. Failure rate by product type
SELECT
    type,
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM machine_readings
GROUP BY type
ORDER BY failure_rate_pct DESC;


-- 6. Average operating conditions: failed vs non-failed
SELECT
    machine_failure,
    ROUND(AVG(air_temperature_k), 2) AS avg_air_temperature_k,
    ROUND(AVG(process_temperature_k), 2) AS avg_process_temperature_k,
    ROUND(AVG(rotational_speed_rpm), 2) AS avg_rotational_speed_rpm,
    ROUND(AVG(torque_nm), 2) AS avg_torque_nm,
    ROUND(AVG(tool_wear_min), 2) AS avg_tool_wear_min
FROM machine_readings
GROUP BY machine_failure;


-- 7. Min / max sensor ranges
SELECT
    MIN(air_temperature_k) AS min_air_temp,
    MAX(air_temperature_k) AS max_air_temp,
    MIN(process_temperature_k) AS min_process_temp,
    MAX(process_temperature_k) AS max_process_temp,
    MIN(rotational_speed_rpm) AS min_rpm,
    MAX(rotational_speed_rpm) AS max_rpm,
    MIN(torque_nm) AS min_torque,
    MAX(torque_nm) AS max_torque,
    MIN(tool_wear_min) AS min_tool_wear,
    MAX(tool_wear_min) AS max_tool_wear
FROM machine_readings;