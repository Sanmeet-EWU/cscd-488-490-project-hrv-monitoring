-- Create the database
CREATE DATABASE HRV;

-- Switch to the newly created database
USE HRV;

-- Create tables
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

-- Create indexes
CREATE INDEX `UserData_index_0` ON `UserData` (`QuestionnaireID`);
CREATE INDEX `UserData_index_1` ON `UserData` (`CurrentMedicationsID`);
CREATE INDEX `TimeSectionDetails_index_2` ON `TimeSectionDetails` (`HeartRateDataID`);
CREATE INDEX `TimeSectionDetails_index_3` ON `TimeSectionDetails` (`MedicationsID`);
CREATE INDEX `TimeSectionDetails_index_4` ON `TimeSectionDetails` (`QuestionnaireID`);

-- Add foreign key relationships
ALTER TABLE `TimeSectionDetails` ADD FOREIGN KEY (`AnonymizedID`) REFERENCES `UserData` (`AnonymizedID`);
ALTER TABLE `HeartRateData` ADD FOREIGN KEY (`HeartRateDataID`) REFERENCES `TimeSectionDetails` (`HeartRateDataID`);
ALTER TABLE `Medication` ADD FOREIGN KEY (`MedicationsID`) REFERENCES `TimeSectionDetails` (`MedicationsID`);
ALTER TABLE `Medication` ADD FOREIGN KEY (`MedicationsID`) REFERENCES `UserData` (`CurrentMedicationsID`);
ALTER TABLE `GAD7Questionnaire` ADD FOREIGN KEY (`QuestionnaireID`) REFERENCES `TimeSectionDetails` (`QuestionnaireID`);
ALTER TABLE `GAD7Questionnaire` ADD FOREIGN KEY (`QuestionnaireID`) REFERENCES `UserData` (`QuestionnaireID`);