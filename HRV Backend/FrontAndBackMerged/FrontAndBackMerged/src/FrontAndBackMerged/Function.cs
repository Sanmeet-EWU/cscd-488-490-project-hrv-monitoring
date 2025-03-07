using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Text.Json;


[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace FrontAndBackMerged;

public class Function
{
    private static MySqlConnection? Connection { get; set; }
    public APIGatewayHttpApiV2ProxyRequest? Request { get; set; }
    public string? RequestType { get; set; }
    public string? AccessKey;
    public string? AnonymizedID;
    public string? HeartRateDataID;
    public string FunctionHandler(APIGatewayHttpApiV2ProxyRequest request, ILambdaContext context)
    {
        try
        {
            if (request is null)
                return "20";
            Request = request;

            bool opened = OpenConnection();
            if (!opened)
                return "21";

            if (!GetRequestType())
                return "22";
            //If we are creating a user, no authorization needs to be done
            if (RequestType == "CreateUser")
                return CreateUser();

            bool authorized = AuthorizeCredentials();
            if (!authorized)
                return "24";

            bool executeRequest = ExecuteRequest();
            if (!executeRequest) return "25";
            return "10";
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unexpected Error: " + Environment.NewLine + ex.Message);
            return "24";
        }
    }


    private bool OpenConnection()
    {
        string? host = Environment.GetEnvironmentVariable("host");
        string? databaseName = Environment.GetEnvironmentVariable("databaseName");
        string? username = Environment.GetEnvironmentVariable("username");
        string? password = Environment.GetEnvironmentVariable("password");
        string? connectionString = $"server={host};port=3306;user={username};password={password};database={databaseName}";

        Connection = new MySqlConnection(connectionString);
        try
        {
            Connection.Open();
        }
        catch
        {
            return false;
        }
        return true;
    }

    private bool AuthorizeCredentials()
    {
        (string? username, string? password) usernameAndPassword = PullAuthInfoFromRequest();
        string? username = usernameAndPassword.username;
        string? password = usernameAndPassword.password;
        if (usernameAndPassword.username is null || usernameAndPassword.password is null)
            return false;

        //Paramaterized to help with attacks
        string query = "SELECT 1 FROM UserData WHERE AnonymizedID = @username AND AccessKey = @password";

        using (MySqlCommand command = new MySqlCommand(query, Connection))
        {
            // Add parameters (Helps with SQL injection)
            command.Parameters.AddWithValue("@username", username);
            command.Parameters.AddWithValue("@password", password);
            //below returns a 1 if match or null if not
            object result = command.ExecuteScalar();

            // Check if result is not null, which indicates a match
            if (result != null)
            {
                Console.WriteLine("Username and password match.");
                return true;
            }
            else
            {
                Console.WriteLine("Invalid username or password.");
                return false;
            }
        }

    }


    private (string?, string?) PullAuthInfoFromRequest()
    {
        try
        {
            JsonDocument doc = JsonDocument.Parse(Request!.Body);
            var body = doc.RootElement.GetProperty("body").ToString();
            var bodyDoc = JsonDocument.Parse(body);

            var requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
            var requestDataDoc = JsonDocument.Parse(requestDataString);


            var AuthInfoString = requestDataDoc.RootElement.GetProperty("AuthInfo").ToString();
            var AuthInfoDoc = JsonDocument.Parse(AuthInfoString);

            string? AnonymizedID = AuthInfoDoc.RootElement.GetProperty("AnonymizedID").GetString();
            string? AccessKey = AuthInfoDoc.RootElement.GetProperty("AccessKey").GetString();
            this.AccessKey = AccessKey;
            this.AnonymizedID = AnonymizedID;
            return (AnonymizedID, AccessKey);
        }
        catch
        {
            return (null, null);
        }
    }

    private bool GetRequestType()
    {
        try
        {

            JsonDocument doc = JsonDocument.Parse(Request!.Body);
            string body = doc.RootElement.GetProperty("body").ToString();
            JsonDocument bodyDoc = JsonDocument.Parse(body);
            string requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
            JsonDocument requestDataDoc = JsonDocument.Parse(requestDataString);
            RequestType = requestDataDoc.RootElement.GetProperty("Type").ToString();
            return true;
        }
        catch
        {
            return false;
        }
    }

    //Returns a comma seperated pair as a string
    private static string CreateUser()
    {

        string AnonymizedID = Guid.NewGuid().ToString();
        string AccessKey = Guid.NewGuid().ToString();

        string query = "INSERT INTO UserData (AccessKey, AnonymizedID) VALUES (@AccessKey, @AnonymizedID)";
        try
        {
            using (MySqlCommand command = new MySqlCommand(query, Connection))
            {
                // Add parameters (Helps with SQL injection)
                command.Parameters.AddWithValue("@AnonymizedID", AnonymizedID);
                command.Parameters.AddWithValue("@AccessKey", AccessKey);
                int result = command.ExecuteNonQuery();
                if (result == 0) throw new InvalidOperationException("Did not write to database.");
                return $"{AnonymizedID},{AccessKey}";
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error when creating new user: " + ex);
            return "23";
        }
    }


    public bool ExecuteRequest()
    {

        switch (RequestType)
        {
            case "UpdateMedications":
                return UpdateMedications();
            case "AddData":
                return AddHeartbeatData();

            case "UpdateQuestionaire":
                return UpdateQuestionnaire();
            default:
                return false;
        }
    }

    public bool AddHeartbeatData()
    {
        //Store Heartbeats
        if (!StoreHeartBeats()) return false;

        if (!StoreTimeSection()) return false;
        //Store Time Section Data
        return true;
    }

    private bool StoreTimeSection()
    {
        

        try
        {
            (string? questionaireID, string? medicationsID) = getUserDataIDS();
            DateTime dateTime = DateTime.Now;
           
            JsonDocument doc = JsonDocument.Parse(Request!.Body);
            string body = doc.RootElement.GetProperty("body").ToString();
            JsonDocument bodyDoc = JsonDocument.Parse(body);
            string requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
            JsonDocument requestData = JsonDocument.Parse(requestDataString);
            //get hrv info
            string hrvInfoString = requestData.RootElement.GetProperty("HRVInfo").ToString();
            JsonDocument hrvInfoJson = JsonDocument.Parse(hrvInfoString);
            double sdnn = hrvInfoJson.RootElement.GetProperty("SDNN").GetDouble();
            double rmssd = hrvInfoJson.RootElement.GetProperty("RMSSD").GetDouble();
            double pnn50 = hrvInfoJson.RootElement.GetProperty("PNN50").GetDouble();
           
            //get flags
            string flagsString = requestData.RootElement.GetProperty("Flags").ToString();
            JsonDocument Flags = JsonDocument.Parse(flagsString);
            bool userFlagged = Flags.RootElement.GetProperty("UserFlagged").GetBoolean();
            bool programFlagged = Flags.RootElement.GetProperty("ProgramFlagged").GetBoolean();
            //get personal Data
            string personalDataString = requestData.RootElement.GetProperty("PersonalData").ToString();
            JsonDocument personalDataJson = JsonDocument.Parse(personalDataString);
            string injuryString = personalDataJson.RootElement.GetProperty("Injury").ToString();
            JsonDocument InjuryDataJson = JsonDocument.Parse(injuryString);
            int age = ((int)personalDataJson.RootElement.GetProperty("Age").GetDouble());
            double bmi = personalDataJson.RootElement.GetProperty("BMI").GetDouble();
            string gender = personalDataJson.RootElement.GetProperty("Gender").ToString();
            string hospitalName = personalDataJson.RootElement.GetProperty("HospitalName").ToString();
            string injuryType = InjuryDataJson.RootElement.GetProperty("Type").ToString();
            string injuryDate = InjuryDataJson.RootElement.GetProperty("Date").ToString();
            string timeSectionID = Guid.NewGuid().ToString();
       
            string insertQuery = "INSERT INTO `TimeSectionDetails` (`AnonymizedID`, `TimeSectionID`, `CreatedAt`, `HeartRateDataID`, `SDNN`, `RMSSD`, `PNN50`, `MedicationsID`, `UserFlagged`, `ProgramFlagged`, `Gender`, `BMI`, `Age`, `HospitalName`, `InjuryType`, `DateOfInjury`, `QuestionnaireID`) " +
                         "VALUES (@AnonymizedID, @TimeSectionID, @CreatedAt, @HeartRateDataID, @SDNN, @RMSSD, @PNN50, @MedicationsID, @UserFlagged, @ProgramFlagged, @Gender, @BMI, @Age, @HospitalName, @InjuryType, @DateOfInjury, @QuestionaireID)";

            // List to hold parameters
            var parameters = new List<MySqlParameter>
            {
                new MySqlParameter("@AnonymizedID", MySqlDbType.VarChar) { Value =  AnonymizedID},
                new MySqlParameter("@TimeSectionID", MySqlDbType.VarChar) { Value = timeSectionID },
                new MySqlParameter("@CreatedAt", MySqlDbType.DateTime) { Value = dateTime },
                new MySqlParameter("@HeartRateDataID", MySqlDbType.VarChar) { Value = HeartRateDataID },
                new MySqlParameter("@SDNN", MySqlDbType.Double) { Value = sdnn },
                new MySqlParameter("@RMSSD", MySqlDbType.Double) { Value = rmssd },
                new MySqlParameter("@PNN50", MySqlDbType.Double) { Value = pnn50 },
                new MySqlParameter("@MedicationsID", MySqlDbType.VarChar) { Value = medicationsID },
                new MySqlParameter("@UserFlagged", MySqlDbType.Bit) { Value = userFlagged },
                new MySqlParameter("@ProgramFlagged", MySqlDbType.Bit) { Value = programFlagged },
                new MySqlParameter("@Gender", MySqlDbType.VarChar) { Value = gender }, // Modify to extract gender
                new MySqlParameter("@BMI", MySqlDbType.Double) { Value = bmi },
                new MySqlParameter("@Age", MySqlDbType.Int32) { Value = age },
                new MySqlParameter("@HospitalName", MySqlDbType.VarChar) { Value = hospitalName },
                new MySqlParameter("@InjuryType", MySqlDbType.VarChar) { Value = injuryType },
                new MySqlParameter("@DateOfInjury", MySqlDbType.DateTime) { Value = injuryDate},
                new MySqlParameter("@QuestionaireID", MySqlDbType.VarChar) { Value = questionaireID }
             };

            //Now we send:
            using (MySqlCommand command = new MySqlCommand(insertQuery, Connection))
            {
                command.Parameters.AddRange(parameters.ToArray());
                int rowsAffected = command.ExecuteNonQuery();


                int expectedRowsAffected = 1;

                if (rowsAffected == expectedRowsAffected)
                {
                    Console.WriteLine($"{rowsAffected} TimeSection row added to database");
                    return true;
                }
                else
                {
                    Console.Write($"{rowsAffected} changed when expected {expectedRowsAffected}");
                    Console.WriteLine("Failure writing TimeSectionData to database");
                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unexpected Error, failure write TimeSection data to database: " + ex);
            return false;
        }


    }
    private (string? medicationsID, string? questionnaireID) getUserDataIDS()
    {
        // SQL query to select both CurrentMedicationsID and QuestionnaireID
        string query = "SELECT CurrentMedicationsID, QuestionnaireID FROM UserData WHERE AnonymizedID = @AnonymizedID AND AccessKey = @AccessKey LIMIT 1";

        // Open connection to the database
        try
        {

            // Create the command and add parameters to avoid SQL injection
            using (var command = new MySqlCommand(query, Connection))
            {
                command.Parameters.AddWithValue("@AnonymizedID", AnonymizedID);
                command.Parameters.AddWithValue("@AccessKey", AccessKey);

                // Execute the query and retrieve both values
                using (var reader = command.ExecuteReader())
                {
                    // If a row is found, read the values
                    if (reader.Read())
                    {
                        string? medicationsID = reader.IsDBNull(reader.GetOrdinal("CurrentMedicationsID")) ? null : reader.GetString(reader.GetOrdinal("CurrentMedicationsID"));
                        string? questionnaireID = reader.IsDBNull(reader.GetOrdinal("QuestionnaireID")) ? null : reader.GetString(reader.GetOrdinal("QuestionnaireID"));

                        return (medicationsID, questionnaireID);
                    }
                    else
                    {
                        // If no data found, return null values
                        return (null, null);
                    }
                }
            }
        }
        catch (Exception ex) {
            Console.WriteLine($"Failed to get Medication and questionaireID {ex}");
            return (null,null);
        }
    }
    private double[] GetHeartBeatsFromJson()
    {
        JsonDocument doc = JsonDocument.Parse(Request!.Body);
        string body = doc.RootElement.GetProperty("body").ToString();
        JsonDocument bodyDoc = JsonDocument.Parse(body);
        string requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
        JsonDocument requestData = JsonDocument.Parse(requestDataString);
        string hrvInfoString = requestData.RootElement.GetProperty("HRVInfo").ToString();
        JsonDocument hrvInfoJson = JsonDocument.Parse(hrvInfoString);
        JsonElement.ArrayEnumerator heartBeatEnumerator = hrvInfoJson.RootElement.GetProperty("HeartBeats").EnumerateArray();
        List<double> heartBeatList = new();
        foreach (var item in heartBeatEnumerator)
        {
            //Console.WriteLine("Added:" + item.GetDouble());
            heartBeatList.Add(item.GetDouble());
        }
        return heartBeatList.ToArray();
    }

    private bool StoreHeartBeats()
    {
        try
        {
            string heartRateDataID = Guid.NewGuid().ToString();
            HeartRateDataID = heartRateDataID;
            string heartRateDataIDParam = "@HeartBeatDataID";
            double[] heartBeats = GetHeartBeatsFromJson();


            string insertQuery = "INSERT INTO `HeartRateData` (`HeartRateDataID`, `Time`, `BPM`) VALUES ";

            // Create a list to hold the parameters for the medications
            var parameters = new List<MySqlParameter>();
            parameters.Add(new MySqlParameter(heartRateDataIDParam, heartRateDataID));

            for (int i = 0; i < heartBeats.Length; i++)
            {
                // Create unique parameter names for each medication entry
                string HeartBeatParamName = $"@BPM{i}";
                insertQuery += $"({heartRateDataIDParam}, {i + 1}, {HeartBeatParamName})";

                // Add the parameter to the parameters list
                parameters.Add(new MySqlParameter(HeartBeatParamName, heartBeats[i]));

                // If it's not the last entry, add a comma for the next row
                if (i < heartBeats.Length - 1)
                {
                    insertQuery += ", ";
                }
            }


            //Now we send:
            using (MySqlCommand command = new MySqlCommand(insertQuery, Connection))
            {
                command.Parameters.AddRange(parameters.ToArray());
                int rowsAffected = command.ExecuteNonQuery();


                int expectedRowsAffected = heartBeats.Length;

                if (rowsAffected == expectedRowsAffected)
                {
                    Console.WriteLine($"{rowsAffected} heartbeats added to database");
                    return true;
                }
                else
                {
                    Console.Write($"{rowsAffected} changed when expected {expectedRowsAffected}");
                    Console.WriteLine("Failure writing heartbeats to database");
                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unexpected Error, failure write heartbeat data to database: " + ex);
            return false;
        }
    }

    public bool UpdateMedications()
    {
        try
        {
            string medicationsID = Guid.NewGuid().ToString();
            string[] medications = GetMedicationsFromJSON();

            string insertQuery = "INSERT INTO `Medication` (`MedicationsID`, `MedicationNumber`, `Medication`) VALUES ";

            // Create a list to hold the parameters for the medications
            var parameters = new List<MySqlParameter>();

            for (int i = 0; i < medications.Length; i++)
            {
                // Create unique parameter names for each medication entry
                string medicationParamName = $"@medication{i}";
                insertQuery += $"(@medicationsId, {i + 1}, {medicationParamName})";

                // Add the parameter to the parameters list
                parameters.Add(new MySqlParameter(medicationParamName, medications[i]));

                // If it's not the last entry, add a comma for the next row
                if (i < medications.Length - 1)
                {
                    insertQuery += ", ";
                }
            }

            // Create the UPDATE query
            string updateQuery = $"; UPDATE `UserData` SET `CurrentMedicationsID` = @medicationsId WHERE `AnonymizedID` = @anonymizedId;";

            // Add the parameters for the UPDATE query
            parameters.Add(new MySqlParameter("@medicationsId", medicationsID));
            parameters.Add(new MySqlParameter("@anonymizedId", this.AnonymizedID));

            // Combine the queries into one final query string
            string finalQuery = insertQuery + updateQuery;
            //Now we send:
            using (MySqlCommand command = new MySqlCommand(finalQuery, Connection))
            {
                command.Parameters.AddRange(parameters.ToArray());
                int rowsAffected = command.ExecuteNonQuery();


                int expectedRowsAffected = medications.Length + 1;  // medications.Length for inserts + 1 for update

                if (rowsAffected == expectedRowsAffected)
                {
                    Console.WriteLine($"{rowsAffected} medications added to database");
                    return true;
                }
                else
                {
                    Console.WriteLine("Failure writing to database");
                    return false;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unexpected Error, failure to write to database: " + ex);
            return false;
        }



    }

    private string[] GetMedicationsFromJSON()
    {
        JsonDocument doc = JsonDocument.Parse(Request!.Body);
        string body = doc.RootElement.GetProperty("body").ToString();
        JsonDocument bodyDoc = JsonDocument.Parse(body);
        string requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
        JsonDocument requestData = JsonDocument.Parse(requestDataString);
        var medicationsEnumerator = requestData.RootElement.GetProperty("Medications").EnumerateArray();
        List<string> medications = new();
        foreach (var item in medicationsEnumerator)
        {
            Console.WriteLine("Added:" + item.GetString());
            medications.Add(item.GetString());
        }
        return medications.ToArray();
    }

    public bool UpdateQuestionnaire()
    {
        try
        {
            string QuestionnaireID = Guid.NewGuid().ToString();
            int[] gad7 = GetGAD7AnswersFromJSON();

            string insertQuery = "INSERT INTO `GAD7Questionnaire` (`QuestionnaireID`, `GAD1`, `GAD2`,`GAD3`,`GAD4`,`GAD5`,`GAD6`,`GAD7`,`Stress`) VALUES (@questionnaireID,";

            // Create a list to hold the parameters for the medications
            var parameters = new List<MySqlParameter>();

            for (int i = 0; i < gad7.Length; i++)
            {
                // Create unique parameter names for each medication entry
                string Gad7ParamName = $"@gad7{i}";
                insertQuery += $"{Gad7ParamName}";
                if (gad7.Length - 1 != i) insertQuery += ",";

                // Add the parameter to the parameters list
                parameters.Add(new MySqlParameter(Gad7ParamName, gad7[i]));

            }
            insertQuery += ")";

            // Create the UPDATE query
            string updateQuery = $"; UPDATE `UserData` SET `QuestionnaireID` = @questionnaireID WHERE `AnonymizedID` = @anonymizedId;";

            // Add the parameters for the UPDATE query
            parameters.Add(new MySqlParameter("@questionnaireID", QuestionnaireID));
            parameters.Add(new MySqlParameter("@anonymizedId", this.AnonymizedID));

            // Combine the queries into one final query string
            string finalQuery = insertQuery + updateQuery;
            //Now we send:
            using (MySqlCommand command = new MySqlCommand(finalQuery, Connection))
            {
                command.Parameters.AddRange(parameters.ToArray());
                int rowsAffected = command.ExecuteNonQuery();


                int expectedRowsAffected = 2;  // medications.Length for inserts + 1 for update

                if (rowsAffected == expectedRowsAffected)
                {
                    Console.WriteLine($"{rowsAffected} GAD7 changes added to database");
                    return true;
                }
                else
                {
                    Console.WriteLine("Failure writing to database");
                    return false;
                }
                
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Unexpected Error, failure to write to database: " + ex);
            return false;
        }

    }

    private int[] GetGAD7AnswersFromJSON()
    {
        JsonDocument doc = JsonDocument.Parse(Request!.Body);
        string body = doc.RootElement.GetProperty("body").ToString();
        JsonDocument bodyDoc = JsonDocument.Parse(body);
        string requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
        JsonDocument requestData = JsonDocument.Parse(requestDataString);
        JsonElement.ArrayEnumerator medicationsEnumerator = requestData.RootElement.GetProperty("Questions").EnumerateArray();
        List<int> QuestionAnswers = new();
        foreach (var item in medicationsEnumerator)
        {
            item.TryGetInt32(out int value);
            Console.WriteLine("Added:" +value+" to array for query");
            QuestionAnswers.Add(value);
        }
        return QuestionAnswers.ToArray();
    }
}