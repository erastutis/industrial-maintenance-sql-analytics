-- 1. Failure type distribution
SELECT 'Tool Wear Failure' AS failure_type, SUM(twf) AS failure_count FROM machine_readings
UNION ALL
SELECT 'Heat Dissipation Failure', SUM(hdf) FROM machine_readings
UNION ALL
SELECT 'Power Failure', SUM(pwf) FROM machine_readings
UNION ALL
SELECT 'Overstrain Failure', SUM(osf) FROM machine_readings
UNION ALL
SELECT 'Random Failure', SUM(rnf) FROM machine_readings
ORDER BY failure_count DESC;


-- 2. Average conditions by failure type
SELECT
    'Tool Wear Failure' AS failure_type,
    ROUND(AVG(tool_wear_min), 2) AS avg_tool_wear,
    ROUND(AVG(torque_nm), 2) AS avg_torque,
    ROUND(AVG(rotational_speed_rpm), 2) AS avg_rpm,
    COUNT(*) AS records
FROM machine_readings
WHERE twf = 1

UNION ALL

SELECT
    'Heat Dissipation Failure',
    ROUND(AVG(tool_wear_min), 2),
    ROUND(AVG(torque_nm), 2),
    ROUND(AVG(rotational_speed_rpm), 2),
    COUNT(*)
FROM machine_readings
WHERE hdf = 1

UNION ALL

SELECT
    'Power Failure',
    ROUND(AVG(tool_wear_min), 2),
    ROUND(AVG(torque_nm), 2),
    ROUND(AVG(rotational_speed_rpm), 2),
    COUNT(*)
FROM machine_readings
WHERE pwf = 1

UNION ALL

SELECT
    'Overstrain Failure',
    ROUND(AVG(tool_wear_min), 2),
    ROUND(AVG(torque_nm), 2),
    ROUND(AVG(rotational_speed_rpm), 2),
    COUNT(*)
FROM machine_readings
WHERE osf = 1

UNION ALL

SELECT
    'Random Failure',
    ROUND(AVG(tool_wear_min), 2),
    ROUND(AVG(torque_nm), 2),
    ROUND(AVG(rotational_speed_rpm), 2),
    COUNT(*)
FROM machine_readings
WHERE rnf = 1;


-- 3. Failed records with multiple failure labels
SELECT
    udi,
    product_id,
    type,
    machine_failure,
    twf,
    hdf,
    pwf,
    osf,
    rnf,
    (twf + hdf + pwf + osf + rnf) AS failure_type_count
FROM machine_readings
WHERE machine_failure = 1
ORDER BY failure_type_count DESC, udi;


-- 4. Failure rate by tool wear segment
SELECT
    CASE
        WHEN tool_wear_min < 50 THEN '0-49'
        WHEN tool_wear_min < 100 THEN '50-99'
        WHEN tool_wear_min < 150 THEN '100-149'
        WHEN tool_wear_min < 200 THEN '150-199'
        ELSE '200+'
    END AS tool_wear_segment,
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM machine_readings
GROUP BY tool_wear_segment
ORDER BY MIN(tool_wear_min);


-- 5. Failure rate by torque segment
SELECT
    CASE
        WHEN torque_nm < 30 THEN '<30'
        WHEN torque_nm < 40 THEN '30-39'
        WHEN torque_nm < 50 THEN '40-49'
        WHEN torque_nm < 60 THEN '50-59'
        ELSE '60+'
    END AS torque_segment,
    COUNT(*) AS total_records,
    SUM(machine_failure) AS total_failures,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS failure_rate_pct
FROM machine_readings
GROUP BY torque_segment
ORDER BY MIN(torque_nm);