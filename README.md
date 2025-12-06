# grpA_27813_Divine_Izabayo_CropsDiseaseEarlyDetection
# Crop Disease Early Detection Management System
## Names: Divine IZABAYO
## ID: 27813
## Course: PL/SQL
## Lecturer: Eric Maniraguha
## institution: Adventist University of Central Africa

##  Table of Contents

- Project Overview
- problem statement
- Features
- System Architecture
- Database Schema
- Installation
- Usage
- Project Phases
- API Documentation
- Testing
- Business Intelligence
- Security
- Future enhancements

---

##  Project Overview

The **Crop Disease Management System** is a comprehensive database solution designed to help farmers, agricultural officers, and administrators in Rwanda track, analyze, and manage crop diseases effectively. The system leverages Oracle Database 23ai's advanced features to provide real-time disease detection, outbreak alerts, and data-driven recommendations.

## Problem statement

Many developing economies still rely heavily on agriculture, yet crop diseases continue to significantly reduce food output. Diseases are frequently discovered by farmers too late, which results in lower yields, higher expenses, and widespread crop loss. In order to assist farmers and agricultural officers in promptly identifying potential diseases based on field-reported symptoms and obtaining early action suggestions, this project offers a Crop Disease Early Detection System constructed using PL/SQL.

### Key Objectives

- **Early Disease Detection:** Enable farmers to report crop diseases quickly and accurately
- **Outbreak Prevention:** Identify and alert on disease outbreak patterns
- **Data-Driven Decisions:** Provide actionable insights through comprehensive analytics
- **Resource Optimization:** Help agricultural officers prioritize interventions
- **Knowledge Sharing:** Build a knowledge base of crop diseases and treatments

### Target Users

- **Farmers:** Report crop diseases and receive treatment recommendations
-  **Agricultural Officers:** Monitor regions and coordinate responses
-  **System Administrators:** Manage users and system configuration
-  **Policy Makers:** Access trends and analytics for resource planning

---

##  Features

### Core Functionality

-  **Disease Reporting:** Simple interface for farmers to submit disease reports
-  **AI-Powered Analysis:** Automated symptom matching and disease identification
-  **Risk Assessment:** Multi-factor risk scoring (severity, confidence, contagion)
-  **Treatment Recommendations:** Context-aware treatment suggestions
-  **Outbreak Alerts:** Automatic generation of alerts based on disease patterns
-  **Geographic Tracking:** Location-based disease monitoring and heat maps
-  **Audit Trail:** Complete logging of all system activities

### Advanced Features

-  **Business Rule Enforcement:** Automatic restriction of operations on weekdays and holidays
-  **Real-time Analytics:** Live dashboards with key performance indicators
-  **Mobile Support:** Optimized for field use on mobile devices



##  System Architecture

### Technology Stack

```

                      
┌─────────────────────────────────────────────┐
│          Application Layer                  │
│  (PL/SQL Packages, Functions, Procedures)   │
└─────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│            Database Layer                   │
│     Oracle Database 23ai Free Release       │
│  (Tables, Triggers, Sequences, Constraints) │
└─────────────────────────────────────────────┘
```

### Core Components

**Database:** Oracle Database 23ai Free Release  
**User:** grpA_divine_cropdiseases_db  
**Privileges:** DBA (Super Admin)  
**Character Set:** UTF-8  
**Date Format:** ISO 8601  

---

##  Database Schema

### Entity Relationship Overview

```
users (15 records)
  ↓
reports (500+ records) ← crops (10 records)
  ↓                      ↓
analysis (100+)      diseases (28 records)
  ↓
recommendations (100+)

outbreak_alerts ← diseases
audit_log (system activity)
trigger_audit_log (operation restrictions)
holidays (public holidays)
```

### Key Tables

| Table | Records | Purpose |
|-------|---------|---------|
| **users** | 15 | User accounts and profiles |
| **crops** | 10 | Crop catalog (Maize, Beans, Rice, etc.) |
| **diseases** | 28 | Disease definitions and characteristics |
| **reports** | 500+ | Farmer-submitted disease reports |
| **analysis** | 100+ | disease analysis |
| **recommendations** | 100+ | Treatment recommendations |
| **outbreak_alerts** | Dynamic | System-generated outbreak alerts |
| **audit_log** | 100+ | System activity audit trail |
| **trigger_audit_log** | Dynamic | Operation restriction logs |
| **holidays** | 2 | Public holiday calendar |

### Database Statistics

- **Total Tables:** 10
- **Total Sequences:** 9
- **Total Triggers:** 4 (2 simple, 2 compound)
- **Total Procedures:** 5
- **Total Functions:** 5
- **Total Packages:** 2
- **Total Indexes:** 3+ custom indexes
- **Total Constraints:** 20+

---

##  Installation

### Prerequisites

- Oracle Database 23ai Free Release 
- Minimum 2GB RAM
- 5GB free disk space

### Step 1: Database Setup

```sql

CONNECT SYSTEM/your_password@localhost:1521/FREEPDB1


CREATE USER grpA_divine_cropdiseases_db IDENTIFIED BY Divine;


GRANT DBA TO grpA_divine_cropdiseases_db;
GRANT UNLIMITED TABLESPACE TO grpA_divine_cropdiseases_db;


CONNECT grpA_divine_cropdiseases_db/Divine@localhost:1521/FREEPDB1
```

### Step 2: Create Schema

Run the installation scripts in order

```sql

SELECT COUNT(*) FROM user_tables;

SELECT 'USERS' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'CROPS', COUNT(*) FROM crops
UNION ALL
SELECT 'DISEASES', COUNT(*) FROM diseases
UNION ALL
SELECT 'REPORTS', COUNT(*) FROM reports;

BEGIN
    crop_pkg.insert_report(
        p_user_id => 1,
        p_crop_id => 1,
        p_symptoms => 'Test symptoms',
        p_severity => 5,
        p_location => 'Kigali'
    );
END;
/
```

---

##  Usage

### For Farmers

#### Submit a Disease Report

```sql

BEGIN
    crop_pkg.insert_report(
        p_user_id => 1,
        p_crop_id => 1, 
        p_symptoms => 'yellowing leaves with rust spots',
        p_severity => 6,
        p_location => 'Rwamagana'
    );
END;
/
```

#### View Your Reports

```sql
SELECT 
    r.report_id,
    c.crop_name,
    r.symptoms_observed,
    r.severity,
    r.status,
    r.report_date
FROM reports r
JOIN crops c ON r.crop_id = c.crop_id
WHERE r.user_id = 1
ORDER BY r.report_date DESC;
```

### For Agricultural Officers

#### View Pending Reports in Your Area

```sql
SELECT 
    r.report_id,
    u.full_name as farmer_name,
    c.crop_name,
    r.symptoms_observed,
    r.severity,
    ROUND((SYSDATE - r.report_date) * 24, 1) as hours_pending
FROM reports r
JOIN users u ON r.user_id = u.user_id
JOIN crops c ON r.crop_id = c.crop_id
WHERE r.REPORT_LOCATION = 'Kigali'
AND r.status = 'PENDING'
ORDER BY r.severity DESC, r.report_date ASC;
```

#### Generate Analysis for a Report

```sql
BEGIN
    crop_pkg.generate_analysis(p_report_id => 201);
END;
/
```

### For Administrators

#### View System Statistics

```sql
SELECT 
    TO_CHAR(SYSDATE, 'YYYY-MM-DD') as report_date,
    (SELECT COUNT(*) FROM users WHERE role = 'Farmer') as total_farmers,
    (SELECT COUNT(*) FROM reports WHERE report_date >= SYSDATE - 30) as reports_last_30_days,
    (SELECT COUNT(*) FROM outbreak_alerts WHERE alert_date >= SYSDATE - 7) as active_outbreaks,
    (SELECT ROUND(AVG(confidence_score), 2) FROM analysis WHERE analysis_date >= SYSDATE - 30) as avg_confidence
FROM dual;
```

#### Update Report Status

```sql
DECLARE
    v_success BOOLEAN;
    v_message VARCHAR2(4000);
BEGIN
    update_report_status(
        p_report_id => 201,
        p_new_status => 'RESPONDED',
        p_notes => 'Treatment recommendation provided',
        p_success => v_success,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || CASE WHEN v_success THEN 'SUCCESS' ELSE 'FAILED' END);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
END;
/
```

---

##  Project Phases

### Phase I-III: Foundation 
- Requirements analysis
- Database design
- ER modeling
- Normalization

### Phase IV: Testing 
**Status:** Complete  
**Deliverables:**
- Test report with 100% pass rate
- Disease identification verified
- Recommendations generated successfully

### Phase V: Table Implementation & Data Insertion 
**Status:** Complete  
**Deliverables:**
- 10 tables created
- 500+ records in main tables
- All constraints enforced
- 100% data integrity



### Phase VI: Database Interaction & Transactions 
**Status:** Complete  
**Deliverables:**
- 5 Procedures with IN/OUT/IN OUT parameters
- 5 Functions (calculation, validation, lookup)
- 1 Advanced package with cursors
- Window functions (ROW_NUMBER, RANK, LAG, LEAD)
- Complete exception handling


### Phase VII: Advanced Programming & Auditing 
**Status:** Complete  
**Deliverables:**
- Holiday management system
- Comprehensive audit logging
- Business rule enforcement (weekday/holiday restrictions)
- 2 Simple triggers
- 1 Compound trigger

**Key Achievements:**
-  6/6 tests passed 
-  All operations blocked on weekdays (as designed)
-  Complete audit trail
-  Clear error messages
-  Autonomous transaction logging

---

##  API Documentation

### Core Package: crop_pkg

#### Functions

**symptom_match**
```sql
FUNCTION symptom_match(
    p_symptoms IN VARCHAR2,
    p_crop_id IN NUMBER
) RETURN t_match_rec;
```
Matches symptoms to diseases using keyword analysis.

**recommendation_lookup**
```sql
FUNCTION recommendation_lookup(
    p_disease_id IN NUMBER,
    p_severity IN NUMBER
) RETURN VARCHAR2;
```
Returns treatment recommendations for identified disease.

#### Procedures

**insert_report**
```sql
PROCEDURE insert_report(
    p_user_id IN NUMBER,
    p_crop_id IN NUMBER,
    p_symptoms IN VARCHAR2,
    p_severity IN NUMBER,
    p_location IN VARCHAR2
);
```
Inserts new disease report with validation.

**generate_analysis**
```sql
PROCEDURE generate_analysis(p_report_id IN NUMBER);
```
Analyzes report and generates recommendations.

### Analytics Package: report_analytics_pkg

**generate_location_report**
```sql
PROCEDURE generate_location_report(p_location IN VARCHAR2);
```
Generates detailed report for specific location.

**get_top_diseases**
```sql
FUNCTION get_top_diseases(
    p_limit IN NUMBER DEFAULT 5
) RETURN SYS_REFCURSOR;
```
Returns top N diseases by occurrence.

### Utility Functions

**calculate_risk_score**
```sql
FUNCTION calculate_risk_score(
    p_severity IN NUMBER,
    p_confidence IN NUMBER,
    p_contagion_level IN VARCHAR2
) RETURN NUMBER;
```

**validate_phone**
```sql
FUNCTION validate_phone(p_phone IN VARCHAR2) RETURN BOOLEAN;
```

**get_user_report_count**
```sql
FUNCTION get_user_report_count(
    p_user_id IN NUMBER,
    p_status IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;
```

---

##  Testing

### Test Coverage

| Component | Tests | Passed | Pass Rate |
|-----------|-------|--------|-----------|
| Phase IV | 1 | 1 | 100% |
| Phase V | 21 | 21 | 100% |
| Phase VI | 11 | 11 | 100% |
| Phase VII | 6 | 6 | 100% |
| **Total** | **39** | **39** | **100%** |

### Running Tests


### Sample Test Output

```
========================================
PHASE VI TESTING - PROCEDURES & FUNCTIONS
========================================

TEST 1: Update Report Status
  Result: SUCCESS
  Message: Report status updated successfully

TEST 2: Generate Monthly Summary
  Total Reports: 150
  High Risk: 45
  Most Affected Crop: Maize

[All tests passed ✓]
```

---

##  Business Intelligence

### Dashboards Available

1. **Executive Dashboard** - High-level KPIs and trends
2. **Operations Dashboard** - Daily workflow monitoring
3. **Analytics Dashboard** - Deep-dive analysis
4. **Geographic Dashboard** - Location-based insights
5. **User Performance Dashboard** - Team metrics

### Key Performance Indicators (33 KPIs)

**Operational:**
- Total Reports: 500+
- Response Rate: 94.5%
- Completion Rate: 90%+

**Health & Safety:**
- Active Outbreaks: 12
- High-Risk Locations: 8
- Average Severity: 5.6/10

**Quality:**
- Average Confidence: 75%+
- Data Completeness: 95%+
- High Confidence Rate: 80%+

### Sample Analytics Query

```sql

SELECT 
    TO_CHAR(r.report_date, 'YYYY-MM') as month,
    c.crop_name,
    d.disease_name,
    COUNT(*) as cases,
    AVG(r.severity) as avg_severity
FROM reports r
JOIN crops c ON r.crop_id = c.crop_id
LEFT JOIN analysis a ON r.report_id = a.report_id
LEFT JOIN diseases d ON a.disease_id = d.disease_id
WHERE r.report_date >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(r.report_date, 'YYYY-MM'), c.crop_name, d.disease_name
ORDER BY month DESC, cases DESC;
```

### Documentation

-  [BI Requirements](business_intelligence/bi_requirements.md)
-  [kpi_definitions](business_intelligence/kpi_definitions.md)


##  Security

### Access Control

**Role-Based Permissions:**

| Feature | Farmer | Officer | Admin |
|---------|--------|---------|-------|
| Submit Reports | yes| yes| yes |
| View Own Reports | yes | no | yes |
| View All Reports | no | yes | yes |
| Generate Analysis | no | yes | yes |
| Manage Users | no | no | yes |
| System Config | no |no | yes|

### Business Rules

**Operation Restrictions:**
-  **Weekdays (Mon-Fri):** All DML operations blocked
-  **Public Holidays:** All DML operations blocked
- **Weekends (Sat-Sun):** Operations allowed

**Enforcement:**
- Database triggers automatically enforce restrictions
- All attempts logged in audit trail
- Clear error messages provided to users

### Audit Trail

All system activities are logged:
- User authentication
- Report submissions
- Analysis generation
- Status updates
- Denied operations
- System configuration changes

**Audit Query:**
```sql
SELECT 
    username,
    operation,
    table_name,
    operation_date,
    is_allowed,
    denial_reason
FROM trigger_audit_log
WHERE operation_date >= SYSDATE - 7
ORDER BY operation_date DESC;
```
## future enhancements

### Planned Features

- [ ] Mobile application (Android/iOS)
- [ ] SMS alert integration
- [ ] Weather data integration
- [ ] Machine learning for disease prediction
- [ ] Multi-language support (Kinyarwanda, English, French)
- [ ] Image-based disease detection
- [ ] Integration with agricultural extension services
- [ ] Farmer training module
- [ ] Crop yield tracking
- [ ] Market price integration

### Technical Improvements

- Performance optimization for 1M+ records
- Data warehouse implementation
- Advanced analytics with Oracle Analytics Cloud
- RESTful API development
- Microservices architecture
- Cloud deployment (Oracle Cloud Infrastructure)

