# KPI Definitions
## Crop Disease Early Detection Management System

**Project:** Crop Disease Management System  
**Student:** Divine  IZABAYO
**Database:** grpA_divine_cropdiseases_db  
**Date:** December 6, 2025  

---

## 1. Document Purpose

This document provides detailed definitions, calculation methods, and SQL queries for all Key Performance Indicators (KPIs) used in the Crop Disease Management System.

---

## 2. Operational KPIs

### 2.1 Total Disease Reports

**Definition:** Total number of disease reports submitted to the system.

**Business Purpose:** Measure system adoption and farmer engagement.

**Calculation:**
```sql
SELECT COUNT(*) as total_reports
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** 100+ reports per month  
**Data Source:** reports table  
**Update Frequency:** Real-time  
**Owner:** Operations Manager  

**Interpretation:**
- Increasing trend = Good (higher engagement)
- Sudden drop = Investigation needed
- Seasonal patterns expected

---

### 2.2 Report Status Distribution

**Definition:** Percentage breakdown of reports by status (PENDING/ANALYZED/RESPONDED).

**Business Purpose:** Track report processing workflow efficiency.

**Calculation:**
```sql
SELECT 
    status,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date
GROUP BY status;
```

**Target:**
- PENDING: < 10%
- ANALYZED: 20-30%
- RESPONDED: > 60%

**Data Source:** reports table  
**Update Frequency:** Hourly  
**Owner:** Operations Manager  

---

### 2.3 Average Response Time

**Definition:** Average time (in hours) from report submission to analysis completion.

**Business Purpose:** Measure system efficiency and responsiveness.

**Calculation:**
```sql
SELECT 
    ROUND(AVG((a.analysis_date - r.report_date) * 24), 2) as avg_hours_to_analyze
FROM reports r
JOIN analysis a ON r.report_id = a.report_id
WHERE r.report_date >= :start_date 
AND r.report_date <= :end_date
AND a.analysis_date IS NOT NULL;
```

**Target:** < 2 hours  
**Data Source:** reports, analysis tables  
**Update Frequency:** Hourly  
**Owner:** Technical Lead  

**Interpretation:**
- < 1 hour = Excellent
- 1-2 hours = Good
- 2-4 hours = Acceptable
- > 4 hours = Needs improvement

---

### 2.4 Report Completion Rate

**Definition:** Percentage of submitted reports that have been fully analyzed.

**Business Purpose:** Track workflow completion and identify bottlenecks.

**Calculation:**
```sql
SELECT 
    COUNT(CASE WHEN status IN ('ANALYZED', 'RESPONDED') THEN 1 END) as completed,
    COUNT(*) as total,
    ROUND(100.0 * COUNT(CASE WHEN status IN ('ANALYZED', 'RESPONDED') THEN 1 END) / 
          COUNT(*), 2) as completion_rate
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** > 90%  
**Data Source:** reports table  
**Update Frequency:** Daily  
**Owner:** Operations Manager  

---

### 2.5 User Adoption Rate

**Definition:** Percentage of registered users who have submitted at least one report.

**Business Purpose:** Measure system adoption and user engagement.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT r.user_id) as active_users,
    COUNT(DISTINCT u.user_id) as total_users,
    ROUND(100.0 * COUNT(DISTINCT r.user_id) / 
          COUNT(DISTINCT u.user_id), 2) as adoption_rate
FROM users u
LEFT JOIN reports r ON u.user_id = r.user_id
WHERE u.role = 'Farmer'
AND (r.report_date >= :start_date OR r.report_date IS NULL);
```

**Target:** > 70%  
**Data Source:** users, reports tables  
**Update Frequency:** Weekly  
**Owner:** Product Manager  

---

## 3. Health & Safety KPIs

### 3.1 Active Outbreaks

**Definition:** Number of current disease outbreaks requiring immediate attention.

**Business Purpose:** Monitor critical health situations.

**Calculation:**
```sql
SELECT COUNT(*) as active_outbreaks
FROM outbreak_alerts
WHERE alert_date >= SYSDATE - 7
AND alert_level IN ('OUTBREAK', 'ADVISORY');
```

**Target:** Minimize (< 5)  
**Data Source:** outbreak_alerts table  
**Update Frequency:** Real-time  
**Owner:** Chief Agricultural Officer  

**Alert Thresholds:**
- 0-3: Green (Normal)
- 4-7: Yellow (Monitor)
- 8+: Red (Critical)

---

### 3.2 High-Risk Location Count

**Definition:** Number of locations with high disease risk levels.

**Business Purpose:** Identify areas requiring intervention.

**Calculation:**
```sql
SELECT COUNT(DISTINCT r.REPORT_LOCATION) as high_risk_locations
FROM reports r
JOIN analysis a ON r.report_id = a.report_id
WHERE r.report_date >= SYSDATE - 30
AND a.risk_level = 'HIGH'
HAVING COUNT(*) >= 3;
```

**Target:** < 10 locations  
**Data Source:** reports, analysis tables  
**Update Frequency:** Daily  
**Owner:** Regional Coordinator  

---

### 3.3 Disease Diversity Index

**Definition:** Number of unique diseases detected across the system.

**Business Purpose:** Monitor disease variety and emerging threats.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT a.disease_id) as unique_diseases,
    COUNT(*) as total_diagnoses,
    ROUND(COUNT(DISTINCT a.disease_id) * 1.0 / COUNT(*), 4) as diversity_index
FROM analysis a
JOIN reports r ON a.report_id = r.report_id
WHERE r.report_date >= :start_date 
AND r.report_date <= :end_date;
```

**Target:** Monitor for sudden increases (potential new disease)  
**Data Source:** analysis, reports tables  
**Update Frequency:** Weekly  
**Owner:** Agricultural Scientist  

---

### 3.4 Average Severity Score

**Definition:** Mean severity level of all reported cases.

**Business Purpose:** Track overall disease impact intensity.

**Calculation:**
```sql
SELECT 
    ROUND(AVG(severity), 2) as avg_severity,
    MIN(severity) as min_severity,
    MAX(severity) as max_severity,
    STDDEV(severity) as severity_stddev
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** < 5.0 (on 1-10 scale)  
**Data Source:** reports table  
**Update Frequency:** Daily  
**Owner:** Health Monitor  

**Interpretation:**
- 1-3: Low impact
- 4-6: Moderate impact
- 7-8: High impact
- 9-10: Critical impact

---

### 3.5 Contagion Risk Score

**Definition:** Weighted score based on disease contagion levels.

**Business Purpose:** Assess overall disease spread risk.

**Calculation:**
```sql
SELECT 
    SUM(CASE d.contagion_level
        WHEN 'HIGH' THEN 3
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 1
        ELSE 0
    END) as total_contagion_score,
    COUNT(*) as total_cases,
    ROUND(AVG(CASE d.contagion_level
        WHEN 'HIGH' THEN 3
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 1
        ELSE 0
    END), 2) as avg_contagion_risk
FROM analysis a
JOIN diseases d ON a.disease_id = d.disease_id
JOIN reports r ON a.report_id = r.report_id
WHERE r.report_date >= :start_date 
AND r.report_date <= :end_date;
```

**Target:** < 2.0 average  
**Data Source:** analysis, diseases, reports tables  
**Update Frequency:** Daily  
**Owner:** Epidemiologist  

---

## 4. Quality & Accuracy KPIs

### 4.1 Analysis Confidence Score

**Definition:** Average confidence level of disease identification.

**Business Purpose:** Measure AI/system accuracy in disease detection.

**Calculation:**
```sql
SELECT 
    ROUND(AVG(confidence_score), 2) as avg_confidence,
    ROUND(MIN(confidence_score), 2) as min_confidence,
    ROUND(MAX(confidence_score), 2) as max_confidence,
    COUNT(CASE WHEN confidence_score >= 70 THEN 1 END) as high_confidence_count,
    ROUND(100.0 * COUNT(CASE WHEN confidence_score >= 70 THEN 1 END) / 
          COUNT(*), 2) as high_confidence_pct
FROM analysis
WHERE analysis_date >= :start_date 
AND analysis_date <= :end_date;
```

**Target:** 
- Average: > 75%
- High confidence (>70%): > 80% of cases

**Data Source:** analysis table  
**Update Frequency:** Daily  
**Owner:** Data Science Team  

---

### 4.2 Data Completeness Rate

**Definition:** Percentage of reports with all required fields populated.

**Business Purpose:** Ensure data quality for accurate analysis.

**Calculation:**
```sql
SELECT 
    COUNT(CASE 
        WHEN user_id IS NOT NULL 
        AND crop_id IS NOT NULL 
        AND symptoms_observed IS NOT NULL
        AND severity IS NOT NULL
        AND REPORT_LOCATION IS NOT NULL
        THEN 1 
    END) as complete_reports,
    COUNT(*) as total_reports,
    ROUND(100.0 * COUNT(CASE 
        WHEN user_id IS NOT NULL 
        AND crop_id IS NOT NULL 
        AND symptoms_observed IS NOT NULL
        AND severity IS NOT NULL
        AND REPORT_LOCATION IS NOT NULL
        THEN 1 
    END) / COUNT(*), 2) as completeness_rate
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** > 95%  
**Data Source:** reports table  
**Update Frequency:** Daily  
**Owner:** Data Quality Manager  

---

### 4.3 Duplicate Report Rate

**Definition:** Percentage of reports that may be duplicates.

**Business Purpose:** Identify data quality issues and user behavior patterns.

**Calculation:**
```sql
WITH duplicates AS (
    SELECT 
        user_id, 
        crop_id, 
        TRUNC(report_date) as report_day,
        REPORT_LOCATION,
        COUNT(*) as dup_count
    FROM reports
    WHERE report_date >= :start_date 
    AND report_date <= :end_date
    GROUP BY user_id, crop_id, TRUNC(report_date), REPORT_LOCATION
    HAVING COUNT(*) > 1
)
SELECT 
    SUM(dup_count) as duplicate_reports,
    (SELECT COUNT(*) FROM reports 
     WHERE report_date >= :start_date 
     AND report_date <= :end_date) as total_reports,
    ROUND(100.0 * SUM(dup_count) / 
        (SELECT COUNT(*) FROM reports 
         WHERE report_date >= :start_date 
         AND report_date <= :end_date), 2) as duplicate_rate
FROM duplicates;
```

**Target:** < 5%  
**Data Source:** reports table  
**Update Frequency:** Weekly  
**Owner:** Data Quality Manager  

---

## 5. Performance & Efficiency KPIs

### 5.1 System Uptime

**Definition:** Percentage of time system is available and operational.

**Business Purpose:** Measure system reliability.

**Calculation:**
```sql
y
SELECT 
    COUNT(DISTINCT TRUNC(operation_date)) as active_days,
    (SYSDATE - :start_date) as total_days,
    ROUND(100.0 * COUNT(DISTINCT TRUNC(operation_date)) / 
          (SYSDATE - :start_date), 2) as uptime_percentage
FROM trigger_audit_log
WHERE operation_date >= :start_date;
```

**Target:** > 99.5%  
**Data Source:** trigger_audit_log table  
**Update Frequency:** Real-time  
**Owner:** System Administrator  

---

### 5.2 Query Performance Index

**Definition:** Average query execution time for standard reports.

**Business Purpose:** Monitor system performance and user experience.

**Calculation:**
```sql

SELECT 
    AVG(elapsed_time) as avg_query_time_ms,
    MAX(elapsed_time) as max_query_time_ms,
    COUNT(CASE WHEN elapsed_time > 5000 THEN 1 END) as slow_queries
FROM query_performance_log
WHERE query_date >= :start_date 
AND query_date <= :end_date;
```

**Target:** 
- Average: < 2 seconds
- Slow queries: < 5%

**Data Source:** Performance monitoring system  
**Update Frequency:** Hourly  
**Owner:** Database Administrator  

---

### 5.3 Reports Per Agricultural Officer

**Definition:** Average number of reports processed per officer.

**Business Purpose:** Measure officer productivity and workload balance.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT u.user_id) as officer_count,
    COUNT(r.report_id) as total_reports,
    ROUND(COUNT(r.report_id) * 1.0 / 
          NULLIF(COUNT(DISTINCT u.user_id), 0), 2) as reports_per_officer
FROM users u
LEFT JOIN reports r ON u.location = r.REPORT_LOCATION
WHERE u.role = 'Officer'
AND r.report_date >= :start_date 
AND r.report_date <= :end_date;
```

**Target:** 50-100 reports per officer per month  
**Data Source:** users, reports tables  
**Update Frequency:** Weekly  
**Owner:** HR Manager  

---

## 6. User Engagement KPIs

### 6.1 Active User Count

**Definition:** Number of unique users who submitted reports in the period.

**Business Purpose:** Track user engagement and system adoption.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT user_id) as active_users,
    COUNT(DISTINCT CASE WHEN role = 'Farmer' THEN user_id END) as active_farmers,
    COUNT(DISTINCT CASE WHEN role = 'Officer' THEN user_id END) as active_officers
FROM reports r
JOIN users u ON r.user_id = u.user_id
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** 
- Farmers: > 100 per month
- Officers: > 10 per month

**Data Source:** reports, users tables  
**Update Frequency:** Daily  
**Owner:** Community Manager  

---

### 6.2 User Retention Rate

**Definition:** Percentage of users who return after first report.

**Business Purpose:** Measure long-term user engagement.

**Calculation:**
```sql
WITH first_report AS (
    SELECT user_id, MIN(report_date) as first_date
    FROM reports
    GROUP BY user_id
),
return_users AS (
    SELECT DISTINCT r.user_id
    FROM reports r
    JOIN first_report fr ON r.user_id = fr.user_id
    WHERE r.report_date > fr.first_date + 7
    AND fr.first_date >= :start_date
)
SELECT 
    COUNT(DISTINCT fr.user_id) as new_users,
    COUNT(DISTINCT ru.user_id) as returned_users,
    ROUND(100.0 * COUNT(DISTINCT ru.user_id) / 
          NULLIF(COUNT(DISTINCT fr.user_id), 0), 2) as retention_rate
FROM first_report fr
LEFT JOIN return_users ru ON fr.user_id = ru.user_id
WHERE fr.first_date >= :start_date;
```

**Target:** > 60%  
**Data Source:** reports table  
**Update Frequency:** Monthly  
**Owner:** Product Manager  

---

### 6.3 Average Reports Per Active User

**Definition:** Mean number of reports submitted per active user.

**Business Purpose:** Measure user engagement intensity.

**Calculation:**
```sql
SELECT 
    COUNT(*) as total_reports,
    COUNT(DISTINCT user_id) as active_users,
    ROUND(COUNT(*) * 1.0 / 
          NULLIF(COUNT(DISTINCT user_id), 0), 2) as reports_per_user
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** > 3 reports per user per month  
**Data Source:** reports table  
**Update Frequency:** Weekly  
**Owner:** Product Manager  

---

## 7. Geographic Coverage KPIs

### 7.1 Location Coverage

**Definition:** Number and percentage of Rwanda districts with active reports.

**Business Purpose:** Measure geographic reach of the system.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT REPORT_LOCATION) as covered_locations,
    15 as total_rwanda_districts, -- Rwanda has ~30 districts
    ROUND(100.0 * COUNT(DISTINCT REPORT_LOCATION) / 15, 2) as coverage_percentage
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** > 80% district coverage  
**Data Source:** reports table  
**Update Frequency:** Monthly  
**Owner:** Expansion Manager  

---

### 7.2 Reports Per Location

**Definition:** Distribution of reports across geographic areas.

**Business Purpose:** Identify under-served or over-represented areas.

**Calculation:**
```sql
SELECT 
    REPORT_LOCATION,
    COUNT(*) as report_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage,
    RANK() OVER (ORDER BY COUNT(*) DESC) as location_rank
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date
GROUP BY REPORT_LOCATION
ORDER BY report_count DESC;
```

**Target:** Balanced distribution (no single location > 20%)  
**Data Source:** reports table  
**Update Frequency:** Weekly  
**Owner:** Regional Coordinator  

---

## 8. Impact & Outcome KPIs

### 8.1 Resolution Rate

**Definition:** Percentage of high-risk reports that reach 'RESPONDED' status.

**Business Purpose:** Measure effectiveness of intervention process.

**Calculation:**
```sql
SELECT 
    COUNT(CASE WHEN r.status = 'RESPONDED' THEN 1 END) as resolved,
    COUNT(*) as total_high_risk,
    ROUND(100.0 * COUNT(CASE WHEN r.status = 'RESPONDED' THEN 1 END) / 
          COUNT(*), 2) as resolution_rate
FROM reports r
JOIN analysis a ON r.report_id = a.report_id
WHERE a.risk_level IN ('HIGH', 'CRITICAL')
AND r.report_date >= :start_date 
AND r.report_date <= :end_date;
```

**Target:** > 80%  
**Data Source:** reports, analysis tables  
**Update Frequency:** Weekly  
**Owner:** Operations Manager  

---

### 8.2 Early Detection Rate

**Definition:** Percentage of diseases caught at low severity levels (1-3).

**Business Purpose:** Measure preventive effectiveness.

**Calculation:**
```sql
SELECT 
    COUNT(CASE WHEN severity <= 3 THEN 1 END) as early_detections,
    COUNT(*) as total_reports,
    ROUND(100.0 * COUNT(CASE WHEN severity <= 3 THEN 1 END) / 
          COUNT(*), 2) as early_detection_rate
FROM reports
WHERE report_date >= :start_date 
AND report_date <= :end_date;
```

**Target:** > 40%  
**Data Source:** reports table  
**Update Frequency:** Monthly  
**Owner:** Health Officer  

---

### 8.3 Recommendation Utilization Rate

**Definition:** Percentage of recommendations that are acted upon.

**Business Purpose:** Measure usefulness and adoption of recommendations.

**Calculation:**
```sql
SELECT 
    COUNT(DISTINCT rec.rec_id) as total_recommendations,
    COUNT(DISTINCT CASE 
        WHEN r.status = 'RESPONDED' THEN rec.rec_id 
    END) as utilized_recommendations,
    ROUND(100.0 * COUNT(DISTINCT CASE 
        WHEN r.status = 'RESPONDED' THEN rec.rec_id 
    END) / COUNT(DISTINCT rec.rec_id), 2) as utilization_rate
FROM recommendations rec
JOIN analysis a ON rec.analysis_id = a.analysis_id
JOIN reports r ON a.report_id = r.report_id
WHERE rec.created_at >= :start_date 
AND rec.created_at <= :end_date;
```

**Target:** > 70%  
**Data Source:** recommendations, analysis, reports tables  
**Update Frequency:** Monthly  
**Owner:** Program Director  

---

## 9. Trend KPIs

### 9.1 Growth Rate

**Definition:** Month-over-month percentage change in report submissions.

**Business Purpose:** Track system adoption trajectory.

**Calculation:**
```sql
WITH monthly_counts AS (
    SELECT 
        TO_CHAR(report_date, 'YYYY-MM') as month,
        COUNT(*) as report_count
    FROM reports
    WHERE report_date >= ADD_MONTHS(SYSDATE, -3)
    GROUP BY TO_CHAR(report_date, 'YYYY-MM')
)
SELECT 
    month,
    report_count,
    LAG(report_count) OVER (ORDER BY month) as prev_month_count,
    ROUND(100.0 * (report_count - LAG(report_count) OVER (ORDER BY month)) / 
          NULLIF(LAG(report_count) OVER (ORDER BY month), 0), 2) as growth_rate
FROM monthly_counts
ORDER BY month DESC;
```

**Target:** Positive growth (> 5% monthly)  
**Data Source:** reports table  
**Update Frequency:** Monthly  
**Owner:** Product Manager  

---

### 9.2 Seasonal Disease Index

**Definition:** Comparative measure of disease activity by season.

**Business Purpose:** Identify seasonal patterns for planning.

**Calculation:**
```sql
SELECT 
    CASE 
        WHEN TO_CHAR(report_date, 'MM') IN ('12','01','02') THEN 'Dry Season'
        WHEN TO_CHAR(report_date, 'MM') IN ('03','04','05') THEN 'Long Rains'
        WHEN TO_CHAR(report_date, 'MM') IN ('06','07','08') THEN 'Long Dry'
        ELSE 'Short Rains'
    END as season,
    COUNT(*) as report_count,
    ROUND(AVG(severity), 2) as avg_severity,
    COUNT(CASE WHEN a.risk_level = 'HIGH' THEN 1 END) as high_risk_count
FROM reports r
LEFT JOIN analysis a ON r.report_id = a.report_id
WHERE report_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY CASE 
        WHEN TO_CHAR(report_date, 'MM') IN ('12','01','02') THEN 'Dry Season'
        WHEN TO_CHAR(report_date, 'MM') IN ('03','04','05') THEN 'Long Rains'
        WHEN TO_CHAR(report_date, 'MM') IN ('06','07','08') THEN 'Long Dry'
        ELSE 'Short Rains'
    END
ORDER BY report_count DESC;
```

**Target:** Understand patterns, no specific target  
**Data Source:** reports, analysis tables  
**Update Frequency:** Quarterly  
**Owner:** Agricultural Scientist  

---

## 10. KPI Monitoring & Alerting

### 10.1 Alert Thresholds

| KPI | Warning Threshold | Critical Threshold |
|-----|------------------|-------------------|
| Response Time | > 2 hours | > 4 hours |
| Completion Rate | < 85% | < 75% |
| Active Outbreaks | > 5 | > 10 |
| System Uptime | < 99% | < 95% |
| Confidence Score | < 70% | < 60% |

### 10.2 Monitoring Query

```sql

WITH kpi_metrics AS (
    SELECT 
        'Response Time' as kpi_name,
        ROUND(AVG((a.analysis_date - r.report_date) * 24), 2) as current_value,
        2 as warning_threshold,
        4 as critical_threshold,
        'hours' as unit
    FROM reports r
    JOIN analysis a ON r.report_id = a.report_id
    WHERE r.report_date >= SYSDATE - 1
    
    UNION ALL
    
    SELECT 
        'Completion Rate' as kpi_name,
        ROUND(100.0 * COUNT(CASE WHEN status != 'PENDING' THEN 1 END) / COUNT(*), 2),
        85,
        75,
        '%'
    FROM reports
    WHERE report_date >= SYSDATE - 7
)
SELECT 
    kpi_name,
    current_value,
    warning_threshold,
    critical_threshold,
    unit,
    CASE 
        WHEN current_value >= critical_threshold THEN 'CRITICAL'
        WHEN current_value >= warning_threshold THEN 'WARNING'
        ELSE 'NORMAL'
    END as status
FROM kpi_metrics;
```

---

## 11. KPI Governance

### 11.1 Review Schedule
- **Daily:** Operational KPIs
- **Weekly:** Performance and engagement KPIs
- **Monthly:** Strategic and impact KPIs
- **Quarterly:** Comprehensive review and adjustment

### 11.2 Ownership Matrix

| KPI Category | Primary Owner | Secondary Owner |
|--------------|--------------|-----------------|
| Operational | Operations Manager | Technical Lead |
| Health & Safety | Chief Agricultural Officer | Health Monitor |
| Quality & Accuracy | Data Quality Manager | Data Science Team |
| Performance | System Administrator | Database Administrator |
| User Engagement | Product Manager | Community Manager |
| Geographic Coverage | Expansion Manager | Regional Coordinator |
| Impact & Outcome | Program Director | Operations Manager |
