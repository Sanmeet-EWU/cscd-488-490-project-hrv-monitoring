Below is a summary of implementation within our chose RDS database.

To create the RDS database cluster:
Use aurora RDS serverless v2
Put it into the VPC
Set lambda to be in the same vpc
Set lambda to be connected within rds page

Create Database
CREATE DATABASE HRV;

Set up tables:

USE HRV;
CREATE TABLE `UserData` (
  `AnonymizedID` varchar(37) NOT NULL,
  `AccessKey` varchar(37) NOT NULL,
  `QuestionnaireID` varchar(37),
  `CurrentMedicationsID` varchar(37),
  PRIMARY KEY (`AnonymizedID`)
);

CREATE TABLE `TimeSectionDetails` (
  `AnonymizedID` varchar(37) NOT NULL,
  `TimeSectionID` varchar(37) NOT NULL,
  `CreatedAt` timestamp,
  `HeartRateDataID` varchar(37) COMMENT 'x amount of time of raw heart rate data',
  `SDNN` double COMMENT 'Single value for this IBI',
  `RMSSD` double COMMENT 'Single value for this IBI',
  `PNN50` double COMMENT 'Single value for this IBI',
  `MedicationsID` varchar(37),
  `UserFlagged` bool COMMENT 'If the user marked this is abnormal',
  `ProgramFlagged` bool COMMENT 'If the program believes this is abnormal',
  `Gender` varchar(37),
  `BMI` double,
  `Age` int,
  `HospitalName` varchar(37) COMMENT 'Null indicates no hospital',
  `InjuryType` varchar(37),
  `DateOfInjury` date,
  `QuestionnaireID` varchar(37),
  PRIMARY KEY (`AnonymizedID`, `TimeSectionID`)
);

CREATE TABLE `GAD7Questionnaire` (
  `QuestionnaireID` varchar(37) NOT NULL,
  `GAD1` int,
  `GAD2` int,
  `GAD3` int,
  `GAD4` int,
  `GAD5` int,
  `GAD6` int,
  `GAD7` int,
  `GAD8` int,
  `Stress` int,
  PRIMARY KEY (`QuestionnaireID`)
);

CREATE TABLE `HeartRateData` (
  `HeartRateDataID` varchar(37),
  `Time` integer,
  `BPM` integer,
  PRIMARY KEY (`HeartRateDataID`, `Time`)
);

CREATE TABLE `Medication` (
  `MedicationsID` varchar(37),
  `MedicationNumber` int,
  `Medication` varchar(37),
  PRIMARY KEY (`MedicationsID`, `MedicationNumber`)
);

CREATE INDEX `UserData_index_0` ON `UserData` (`QuestionnaireID`);
CREATE INDEX `UserData_index_1` ON `UserData` (`CurrentMedicationsID`);
CREATE INDEX `TimeSectionDetails_index_2` ON `TimeSectionDetails` (`HeartRateDataID`);
CREATE INDEX `TimeSectionDetails_index_3` ON `TimeSectionDetails` (`MedicationsID`);
CREATE INDEX `TimeSectionDetails_index_4` ON `TimeSectionDetails` (`QuestionnaireID`);

ALTER TABLE `TimeSectionDetails` ADD FOREIGN KEY (`AnonymizedID`) REFERENCES `UserData` (`AnonymizedID`);

ALTER TABLE `HeartRateData` ADD FOREIGN KEY (`HeartRateDataID`) REFERENCES `TimeSectionDetails` (`HeartRateDataID`);

ALTER TABLE `GAD7Questionnaire` ADD FOREIGN KEY (`QuestionnaireID`) REFERENCES `TimeSectionDetails` (`QuestionnaireID`);

ALTER TABLE `GAD7Questionnaire` ADD FOREIGN KEY (`QuestionnaireID`) REFERENCES `UserData` (`QuestionnaireID`);

To add a user:
USE HRV;
INSERT INTO `UserData` (`AnonymizedID`, `AccessKey`, `QuestionnaireID`, `CurrentMedicationsID`)
VALUES ('generated-anonymized-uuid', 'generated-access-key-uuid', null, null);


To add HRV Value for the format:
We first pull the users MedicationID, and Questionnaire ID to use for our insert:
USE HRV;
SELECT `QuestionnaireID`, `CurrentMedicationsID`
FROM `UserData`
WHERE `AnonymizedID` = 'generated-anonymized-uuid';


Then we create a time section entry:
USE HRV;
INSERT INTO `TimeSectionDetails` 
(`AnonymizedID`, `TimeSectionID`, `CreatedAt`, `HeartRateDataID`, `SDNN`, `RMSSD`, `PNN50`, `MedicationsID`, `UserFlagged`, `ProgramFlagged`, `Gender`, `BMI`, `Age`, `HospitalName`, `InjuryType`, `DateOfInjury`, `QuestionnaireID`)
VALUES
('generated-anonymized-uuid', 'generated-TimeSectionDetails-uuid', '2024-12-01 08:00:00', 'generated-HeartRateID-uuid', 50.2, 35.5, 10.0, 'generated-MedicationsID-uuid', FALSE, TRUE, 'Male', 22.5, 30, 'St.Jude', 'Sprain', '2024-11-25', 'generated-Questionnaire-uuid');

INSERT INTO `HeartRateData` 
(`HeartRateDataID`, `Time`, `BPM`)
VALUES
('generated-HeartRateID-uuid', 1, 72),
('generated-HeartRateID-uuid', 2, 75),
('generated-HeartRateID-uuid', 3, 70);



To update Medications:
Use HRV;
INSERT INTO `Medication` 
(`MedicationsID`, `MedicationNumber`, `Medication`)
VALUES
('generated-MedicationsID-uuid', 1, 'Aspirin'),
('generated-MedicationsID-uuid', 2, 'Ibuprofen');

UPDATE `UserData`
SET `CurrentMedicationsID` = 'generated-MedicationsID-uuid'
WHERE `AnonymizedID` = 'generated-anonymized-uuid';

To update Questionnaire:
Use HRV;
INSERT INTO `GAD7Questionnaire` 
(`QuestionnaireID`, `GAD1`, `GAD2`, `GAD3`, `GAD4`, `GAD5`, `GAD6`, `GAD7`, `GAD8`, `Stress`)
VALUES
('generated-Questionnaire-uuid', 3, 4, 2, 5, 2, 3, 1, 4, 0);

UPDATE `UserData` 
SET `QuestionnaireID` = 'generated-Questionnaire-uuid'
WHERE `AnonymizedID` = 'generated-anonymized-uuid';

To view all the tables:

Use HRV;
select * from UserData;
select * from TimeSectionDetails;
select * from Medication;
select * from GAD7Questionnaire;
select * from HeartRateData;


For the lambda, ensure that you use the auto connect feature, and check out the code in below files to implement.
