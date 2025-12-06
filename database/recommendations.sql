CREATE TABLE recommendations (
  rec_id              NUMBER(12) PRIMARY KEY,
  analysis_id         NUMBER(12) NOT NULL,
  recommendation_text VARCHAR2(4000),
  created_at          DATE DEFAULT SYSDATE,
  CONSTRAINT fk_rec_analysis FOREIGN KEY (analysis_id) REFERENCES analysis(analysis_id) ON DELETE CASCADE
);