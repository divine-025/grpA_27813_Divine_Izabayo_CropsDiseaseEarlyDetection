# Business Intelligence Requirements
## Crop Disease Early Detection Management System

**Project:** Crop Disease Management System  
**Student:** Divine  IZABAYO
**Database:** grpA_divine_cropdiseases_db  
**Date:** December 6, 2025  

---

## 1. Executive Summary

This document outlines the Business Intelligence (BI) requirements for the Crop Disease Management System. The BI solution will provide real-time insights into crop disease patterns, outbreak trends, user activity, and system performance to support data-driven decision-making for agricultural stakeholders in Rwanda.

---

## 2. Business Objectives

### 2.1 Primary Objectives
- Monitor disease outbreak patterns across different locations
- Track system usage and user engagement
- Identify high-risk areas requiring immediate intervention
- Measure disease identification accuracy and confidence levels
- Support resource allocation decisions for agricultural officers

### 2.2 Key Stakeholders
- **Agricultural Officers:** Need outbreak alerts and location-based trends
- **System Administrators:** Require system performance and usage metrics
- **Farmers:** Need disease prevention insights
- **Policy Makers:** Require regional disease trends for resource planning

---

## 3. Data Sources

### 3.1 Primary Tables

**Operational Tables:**
```sql
users           
crops           
diseases        
reports         -
analysis        
recommendations 
outbreak_alerts 
audit_log       
trigger_audit_log 
holidays        
```

### 3.2 Data Refresh Requirements

| Data Type | Refresh Frequency | Rationale |
|-----------|------------------|-----------|
| Disease Reports | Real-time | Critical for outbreak detection |
| Analysis Results | Real-time | Immediate decision support needed |
| User Activity | Hourly | Sufficient for monitoring |
| Aggregated Trends | Daily | Historical analysis |
| Outbreak Alerts | Real-time | Emergency response required |

---

## 4. Analytical Requirements

### 4.1 Required Analysis Dimensions

**Geographic Dimension:**
- Location (District/Sector level)
- Regional groupings
- Rural vs Urban classification

**Temporal Dimension:**
- Daily trends
- Weekly patterns
- Monthly comparisons
- Seasonal analysis
- Year-over-year comparison

**Crop Dimension:**
- Crop type
- Crop family
- Economic importance

**Disease Dimension:**
- Disease name
- Contagion level (LOW/MEDIUM/HIGH)
- Risk level (LOW/MEDIUM/HIGH/CRITICAL)

**User Dimension:**
- User role (Farmer/Officer/Admin)
- Location
- Activity level

---

### 4.2 Required Metrics (See kpi_definitions.md)

**Operational Metrics:**
- Total reports submitted
- Reports by status
- Average response time
- User adoption rate

**Health Metrics:**
- Disease outbreak frequency
- High-risk area count
- Average confidence score
- Most common diseases

**Performance Metrics:**
- System availability
- Analysis accuracy
- User engagement rate
- Report completion rate

---

## 5. Reporting Requirements

### 5.1 Standard Reports

**Daily Reports:**
- Disease Report Summary
- High-Risk Alerts
- User Activity Log
- System Performance Metrics

**Weekly Reports:**
- Disease Trend Analysis
- Location-Based Outbreak Summary
- User Engagement Statistics
- Top 10 Diseases by Frequency

**Monthly Reports:**
- Comprehensive Disease Analysis
- Geographic Heat Maps
- Seasonal Pattern Analysis
- System Usage Statistics

**Ad-hoc Reports:**
- Custom date range analysis
- Specific location deep-dive
- Disease-specific investigation
- User activity audit

---

### 5.2 Report Distribution

| Report Type | Audience | Format | Delivery Method |
|-------------|----------|--------|-----------------|
| Daily Dashboard | Officers, Admins | Interactive | Web Portal |
| Weekly Summary | All Stakeholders | PDF | Email |
| Monthly Analysis | Policy Makers | PDF + Excel | Email + Portal |
| Outbreak Alerts | Officers, Farmers | SMS + Email | Push Notification |

---

## 6. Dashboard Requirements (See dashboards.md)

### 6.1 Executive Dashboard
- High-level KPIs
- Trend indicators
- Critical alerts
- Regional overview map

### 6.2 Operations Dashboard
- Real-time report status
- Pending analysis queue
- User activity feed
- System health indicators

### 6.3 Analytics Dashboard
- Disease pattern analysis
- Predictive trends
- Comparative analysis
- Root cause identification

### 6.4 Geographic Dashboard
- Interactive map view
- Location-based filtering
- Outbreak hotspots
- Regional comparisons

---

## 7. Data Quality Requirements

### 7.1 Completeness
- **Minimum completeness:** 95% for critical fields
- **Critical fields:** user_id, crop_id, symptoms, severity, location, report_date
- **Validation:** Automated checks on data entry

### 7.2 Accuracy
- **Disease identification accuracy:** Target 80%+
- **Location accuracy:** 100% (validated against district list)
- **Severity assessment:** Regular calibration with field observations

### 7.3 Timeliness
- **Report entry to analysis:** < 5 minutes
- **Analysis to recommendation:** < 2 minutes
- **Alert generation:** < 1 minute for critical cases

### 7.4 Consistency
- **Standardized disease names:** Controlled vocabulary
- **Standardized locations:** District-level naming convention
- **Date formats:** ISO 8601 standard

---

## 8. Analytical SQL Queries

### 8.1 Disease Trend Analysis
```sql

SELECT 
    TO_CHAR(r.report_date, 'YYYY-MM') as month,
    c.crop_name,
    d.disease_name,
    COUNT(*) as report_count,
    AVG(r.severity) as avg_severity,
    AVG(a.confidence_score) as avg_confidence
FROM reports r
JOIN crops c ON r.crop_id = c.crop_id
LEFT JOIN analysis a ON r.report_id = a.report_id
LEFT JOIN diseases d ON a.disease_id = d.disease_id
WHERE r.report_date >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(r.report_date, 'YYYY-MM'), c.crop_name, d.disease_name
ORDER BY month DESC, report_count DESC;
```

### 8.2 Geographic Hotspot Analysis
```sql

SELECT 
    r.REPORT_LOCATION,
    COUNT(DISTINCT r.report_id) as total_reports,
    COUNT(DISTINCT CASE WHEN a.risk_level = 'HIGH' THEN r.report_id END) as high_risk_reports,
    COUNT(DISTINCT d.disease_id) as unique_diseases,
    ROUND(AVG(r.severity), 2) as avg_severity,
    ROUND(100.0 * COUNT(CASE WHEN a.risk_level = 'HIGH' THEN 1 END) / 
          NULLIF(COUNT(*), 0), 2) as high_risk_percentage
FROM reports r
LEFT JOIN analysis a ON r.report_id = a.report_id
LEFT JOIN diseases d ON a.disease_id = d.disease_id
WHERE r.report_date >= SYSDATE - 30
GROUP BY r.REPORT_LOCATION
HAVING COUNT(DISTINCT r.report_id) >= 5
ORDER BY high_risk_percentage DESC, total_reports DESC;
```

### 8.3 System Performance Metrics
```sql

SELECT 
    TRUNC(report_date) as report_day,
    COUNT(*) as total_reports,
    COUNT(CASE WHEN status = 'ANALYZED' THEN 1 END) as analyzed_reports,
    COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_reports,
    ROUND(100.0 * COUNT(CASE WHEN status = 'ANALYZED' THEN 1 END) / COUNT(*), 2) as completion_rate,
    ROUND(AVG(severity), 2) as avg_severity
FROM reports
WHERE report_date >= SYSDATE - 7
GROUP BY TRUNC(report_date)
ORDER BY report_day DESC;
```

### 8.4 User Engagement Analysis
```sql

SELECT 
    u.role,
    u.location,
    COUNT(DISTINCT u.user_id) as user_count,
    COUNT(r.report_id) as total_reports,
    ROUND(AVG(COUNT(r.report_id)) OVER (PARTITION BY u.role), 2) as avg_reports_per_role,
    MAX(r.report_date) as last_activity
FROM users u
LEFT JOIN reports r ON u.user_id = r.user_id
WHERE r.report_date >= SYSDATE - 30 OR r.report_date IS NULL
GROUP BY u.role, u.location
ORDER BY total_reports DESC;
```

### 8.5 Disease Identification Accuracy
```sql
SELECT 
    d.disease_name,
    d.contagion_level,
    COUNT(*) as diagnosis_count,
    ROUND(AVG(a.confidence_score), 2) as avg_confidence,
    ROUND(MIN(a.confidence_score), 2) as min_confidence,
    ROUND(MAX(a.confidence_score), 2) as max_confidence,
    COUNT(CASE WHEN a.confidence_score >= 70 THEN 1 END) as high_confidence_count,
    ROUND(100.0 * COUNT(CASE WHEN a.confidence_score >= 70 THEN 1 END) / COUNT(*), 2) as high_confidence_pct
FROM analysis a
JOIN diseases d ON a.disease_id = d.disease_id
GROUP BY d.disease_name, d.contagion_level
ORDER BY diagnosis_count DESC;
```

### 8.6 Outbreak Alert Analysis
```sql

SELECT 
    oa.location,
    d.disease_name,
    c.crop_name,
    oa.alert_level,
    oa.number_of_cases,
    TO_CHAR(oa.alert_date, 'YYYY-MM-DD') as alert_date,
    d.contagion_level,
    CASE 
        WHEN oa.alert_level = 'OUTBREAK' THEN 'CRITICAL - Immediate Action Required'
        WHEN oa.alert_level = 'ADVISORY' THEN 'WARNING - Monitor Closely'
        WHEN oa.alert_level = 'WATCH' THEN 'CAUTION - Increased Vigilance'
    END as action_required
FROM outbreak_alerts oa
JOIN diseases d ON oa.disease_id = d.disease_id
JOIN crops c ON d.crop_id = c.crop_id
WHERE oa.alert_date >= SYSDATE - 30
ORDER BY 
    CASE oa.alert_level 
        WHEN 'OUTBREAK' THEN 1 
        WHEN 'ADVISORY' THEN 2 
        WHEN 'WATCH' THEN 3 
    END,
    oa.number_of_cases DESC;
```

---

## 9. Advanced Analytics Requirements

### 9.1 Predictive Analytics
- Disease outbreak prediction based on historical patterns
- Seasonal trend forecasting
- Risk score prediction for new reports
- Resource demand forecasting

### 9.2 Comparative Analytics
- Year-over-year disease comparisons
- Location performance benchmarking
- Crop vulnerability analysis
- Intervention effectiveness measurement

### 9.3 Root Cause Analysis
- Common symptom patterns
- Environmental factor correlation
- Crop rotation impact
- Weather pattern relationships

---

## 10. Technical Requirements

### 10.1 Performance Requirements
- Dashboard load time: < 3 seconds
- Query execution time: < 5 seconds for standard reports
- Real-time alerts: < 30 seconds latency
- Concurrent users: Support 50+ simultaneous users

### 10.2 Scalability Requirements
- Data volume: Support 100,000+ reports/year
- User growth: Accommodate 500+ active users
- Geographic expansion: Support all Rwanda districts
- Historical data: Maintain 5+ years of data

### 10.3 Security Requirements
- Role-based access control
- Data encryption at rest and in transit
- Audit trail for all data access
- Compliance with data privacy regulations

---

## 11. Integration Requirements

### 11.1 Data Sources
- Direct database connection to Oracle 23ai
- Real-time data feeds from application layer
- Manual data upload capability (CSV/Excel)
- API integration for external weather data

### 11.2 Export Capabilities
- PDF report generation
- Excel export for detailed analysis
- CSV export for data sharing
- API endpoints for third-party integration

---

## 12. User Requirements

### 12.1 Farmer Portal
- Simple disease report submission
- View personal report history
- Receive treatment recommendations
- Access educational resources

### 12.2 Officer Portal
- Monitor assigned geographic area
- Review pending reports
- Generate location-specific reports
- Issue outbreak alerts

### 12.3 Admin Portal
- System-wide analytics
- User management
- Configuration settings
- System health monitoring

---

## 13. Training Requirements

### 13.1 User Training
- Dashboard navigation
- Report interpretation
- Alert response procedures
- Data quality guidelines

### 13.2 Technical Training
- Report development
- Query optimization
- Dashboard customization
- System administration

---

## 14. Success Criteria

### 14.1 Adoption Metrics
- 80%+ of agricultural officers using system daily
- 60%+ of farmers submitting regular reports
- 90%+ user satisfaction score

### 14.2 Performance Metrics
- 95%+ system uptime
- < 5 minute average report processing time
- 80%+ disease identification accuracy

### 14.3 Business Impact
- 30% reduction in disease outbreak response time
- 25% improvement in crop yield in monitored areas
- 50% increase in early disease detection

---

## 15. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- Database optimization
- Core KPI development
- Basic dashboard creation

### Phase 2: Enhancement (Weeks 3-4)
- Advanced analytics implementation
- Geographic visualization
- Alert system integration

### Phase 3: Optimization (Weeks 5-6)
- Performance tuning
- User feedback incorporation
- Training material development

### Phase 4: Deployment (Week 7-8)
- User training
- Production rollout
- Monitoring and support

---

## 16. Maintenance & Support

### 16.1 Regular Maintenance
- Weekly data quality checks
- Monthly performance reviews
- Quarterly dashboard updates
- Annual requirement reviews

### 16.2 Support Structure
- Help desk for user queries
- Technical support for system issues
- On-call support for critical alerts
- Regular user feedback sessions

---

