CREATE TABLE reports (
  report_id          NUMBER(12) PRIMARY KEY,
  user_id            NUMBER(10) NOT NULL,
  crop_id            NUMBER(10) NOT NULL,
  symptoms_observed  VARCHAR2(1000) NOT NULL,
  severity           NUMBER(3) DEFAULT 5 CHECK (severity BETWEEN 1 AND 10),
  report_location    VARCHAR2(200),
  report_date        DATE DEFAULT SYSDATE,
  status             VARCHAR2(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING','ANALYZED','RESPONDED')),
  CONSTRAINT fk_reports_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_reports_crop FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
);
ALTER TABLE reports ADD CONSTRAINT fk_reports_user 
  FOREIGN KEY (user_id) REFERENCES users(user_id);
  
ALTER TABLE reports ADD CONSTRAINT fk_reports_crop 
  FOREIGN KEY (crop_id) REFERENCES crops(crop_id);