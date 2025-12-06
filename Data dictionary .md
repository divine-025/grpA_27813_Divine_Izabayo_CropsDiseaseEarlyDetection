**Crop Disease Early Detection System Data Dictionary** 

**USERS** 

| Field  | Type  | Size  | Key  | Description |
| :---- | ----- | ----- | ----- | ----- |
| user\_id  | NUMBER  | 10  | PK  | Unique identifier |
| user\_name  | VARCHAR2  | 100  |  | Full name |
| phone  | VARCHAR2  | 20  |  | Phone |
| role  | VARCHAR2  | 20  |  | Role |

**CROPS** 

| Field  | Type  | Size  | Key  | Description |
| ----- | ----- | ----- | ----- | ----- |
| crop\_id  | NUMBER  | 10  | PK  | Crop ID |
| crop\_name  | VARCHAR2  | 50  |  | Name |
| description  | VARCHAR2  | 200  |  | Description |

**DISEASES** 

| Field  | Type  | Size  | Key  | Description |
| ----- | ----- | ----- | ----- | ----- |
| disease\_id  | NUMBER  | 10  | PK  | Disease ID |
| crop\_id  | NUMBER  | 10  | FK  | Crop |
| disease\_name  | VARCHAR2  | 100  |  | Name |
| typical\_symptoms  | VARCHAR2  | 300  |  | Symptoms |
| contagion\_level  | VARCHAR2  | 20  |  | Level |

**REPORTS**

| Field  | Type  | Size  | Key  | Description |
| :---- | :---- | ----- | :---: | ----- |
| report\_id  | NUMBER  | 10  | PK  | Report ID |
| user\_id  | NUMBER  | 10  | FK  | User |
| crop\_id | NUMBER | 10 | FK | cp |
| symptoms | VARCHAR2 | 400 |  | symptoms |
| report\_date | DATE |  |  | date |
| severity | VARCHAR2 | 20 |  | status |
| location | VARCHAR2 | 50 |  | location |

**ANALYSIS** 

| Field  | Type  | Size  | Key  | Description |
| ----- | ----- | ----- | ----- | ----- |
| analysis\_id  | NUMBER  | 10  | PK  | Analysis ID |
| report\_id  | NUMBER  | 10  | FK  | Report |
| disease\_id  | NUMBER  | 10  | FK  | Disease |
| risk\_level  | VARCHAR2  | 20  |  | Risk |
| confidence\_score  | NUMBER  | 5,2  |  | Confidence |
| analysis\_date  | DATE  |  |  | Date |

**RECOMMENDATIONS** 

| Field  | Type  | Size  | Key  | Description |
| ----- | ----- | ----- | ----- | ----- |
| rec\_id  | NUMBER  | 10  | PK  | Recommendation |
| analysis\_id  | NUMBER  | 10  | FK  | Analysis |
| recommendation\_text  | VARCHAR2  | 500  |  | Text |

**OUTBREAK\_ALERTS** 

| Field  | Type  | Size  | Key  | Description |
| ----- | ----- | ----- | ----- | ----- |
| alert\_id  | NUMBER  | 10  | PK  | Alert |
| disease\_id  | NUMBER  | 10  | FK  | Disease |
| alert\_level  | VARCHAR2  | 20  |  | Level |
| alert\_date  | DATE  |  |  | Date |
| location  | VARCHAR2  | 100  |  | Location |
| number\_of\_cases | NUMBER | 10 |  | Cases count. .  |

**AUDIT\_LOG**

| Field  | Type  | Size  | Key  | Description |
| :---- | ----- | ----- | ----- | ----- |
| audit\_id  | NUMBER  | 10  | PK  | Log |
| user\_id  | NUMBER  | 10  | FK  | User |
| action  | VARCHAR2  | 200  |  | Action |
| action\_time | DATE  |  |  | Time |
| status | VARCHAR2 | 200 |  | Status |
| notes | VARCHAR2 | 200 |  | Notes |

**Project Assumptions** 

**Functional Assumptions:** 

1\. Farmers submit one report for one crop at a time. 

2\. Analysis predicts one disease per report. 

3\. Outbreak detection uses similar reports within the same location. 

4\. District officers receive outbreak alerts. 

5\. BI Team uses external tools such as Power BI connected to the DB. 

6\. Historical data is stored for future predictions. 

7\. Reports are not deleted, only updated. 

8\. Only registered users can submit reports. 

**Technical Assumptions:** 

1\. Oracle Database is used. 

2\. PL/SQL is used for all backend logic. 

3\. Primary keys are generated using sequences. 

4\. SYSDATE used for timestamps.  
5\. Foreign keys enforce data integrity. 

6\. All tables meet 3NF minimum. 

7\. Audit logs capture all user-triggered actions. 

**Data Quality Assumptions:** 

1\. User input is validated before saving. 

2\. Phone numbers are unique and properly formatted. 

3\. Disease and crop lists are maintained by administrators. 