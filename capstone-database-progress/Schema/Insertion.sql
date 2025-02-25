-- Insert a user into UserData table 
USE HRV;
INSERT INTO `UserData` (`AnonymizedID`, `AccessKey`, `QuestionnaireID`, `CurrentMedicationsID`)
VALUES ('generated-anonymized-uuid', 'generated-access-key-uuid', null, null);

-- Fetch user's QuestionnaireID and CurrentMedicationsID for inserting TimeSectionDetails (not given in json so must be pulled, but not really needed here)
SELECT `QuestionnaireID`, `CurrentMedicationsID`
FROM `UserData`
WHERE `AnonymizedID` = 'generated-anonymized-uuid';

-- Insert a time section entry
USE HRV;
INSERT INTO `TimeSectionDetails` 
(`AnonymizedID`, `TimeSectionID`, `CreatedAt`, `HeartRateDataID`, `SDNN`, `RMSSD`, `PNN50`, `MedicationsID`, `UserFlagged`, `ProgramFlagged`, `Gender`, `BMI`, `Age`, `HospitalName`, `InjuryType`, `DateOfInjury`, `QuestionnaireID`)
VALUES
('generated-anonymized-uuid', 'generated-TimeSectionDetails-uuid', '2024-12-01 08:00:00', 'generated-HeartRateID-uuid', 50.2, 35.5, 10.0, 'generated-MedicationsID-uuid', FALSE, TRUE, 'Male', 22.5, 30, 'St.Jude', 'Sprain', '2024-11-25', 'generated-Questionnaire-uuid');

-- Insert heart rate data for the time section
INSERT INTO `HeartRateData` 
(`HeartRateDataID`, `Time`, `BPM`)
VALUES
('generated-HeartRateID-uuid', 1, 72),
('generated-HeartRateID-uuid', 2, 75),
('generated-HeartRateID-uuid', 3, 70);

-- Insert medications into Medication table
USE HRV;
INSERT INTO `Medication` 
(`MedicationsID`, `MedicationNumber`, `Medication`)
VALUES
('generated-MedicationsID-uuid', 1, 'Aspirin'),
('generated-MedicationsID-uuid', 2, 'Ibuprofen');

-- Update user's CurrentMedicationsID in UserData
UPDATE `UserData`
SET `CurrentMedicationsID` = 'generated-MedicationsID-uuid'
WHERE `AnonymizedID` = 'generated-anonymized-uuid';

-- Insert GAD7 Questionnaire data
USE HRV;
INSERT INTO `GAD7Questionnaire` 
(`QuestionnaireID`, `GAD1`, `GAD2`, `GAD3`, `GAD4`, `GAD5`, `GAD6`, `GAD7`, `GAD8`, `Stress`)
VALUES
('generated-Questionnaire-uuid', 3, 4, 2, 5, 2, 3, 1, 4, 0);

-- Update user's QuestionnaireID in UserData
UPDATE `UserData` 
SET `QuestionnaireID` = 'generated-Questionnaire-uuid'
WHERE `AnonymizedID` = 'generated-anonymized-uuid';

-- View all data in the tables
SELECT * FROM UserData;
SELECT * FROM TimeSectionDetails;
SELECT * FROM Medication;
SELECT * FROM GAD7Questionnaire;
SELECT * FROM HeartRateData;
