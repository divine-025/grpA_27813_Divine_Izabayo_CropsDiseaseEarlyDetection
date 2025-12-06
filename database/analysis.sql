CREATE TABLE analysis (
  analysis_id      NUMBER(12) PRIMARY KEY,
  report_id        NUMBER(12) NOT NULL UNIQUE,
  disease_id       NUMBER(10),
  risk_level       VARCHAR2(20) CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
  confidence_score NUMBER(5,2) CHECK (confidence_score BETWEEN 0 AND 100),
  analysis_date    DATE DEFAULT SYSDATE,
  CONSTRAINT fk_analysis_report FOREIGN KEY (report_id) REFERENCES reports(report_id) ON DELETE CASCADE,
  CONSTRAINT fk_analysis_disease FOREIGN KEY (disease_id) REFERENCES diseases(disease_id)
);