-- Test with different symptoms (should match Maize Rust - disease_id=1)
BEGIN
   crop_pkg.insert_report(
      p_user_id => 1,
      p_crop_id => 1,
      p_symptoms => 'rust spots and yellowing leaves',
      p_severity => 4,
      p_location => 'Kayonza'
   );
END;
/

-- Get the new report_id and analyze it
SELECT report_id FROM reports WHERE status='PENDING' ORDER BY report_id DESC FETCH FIRST 1 ROW ONLY;

-- Then analyze (replace XXX with the report_id from above)
BEGIN
   crop_pkg.generate_analysis(XXX);
END;
/