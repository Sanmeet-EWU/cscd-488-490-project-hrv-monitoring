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
                return AddData();

            case "UpdateQuestionaire":
                return UpdateQuestionaire();
            default:
                return false;
        }
    }

    public bool AddData()
    {
        throw new NotImplementedException();
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
                PrintExecutingQuery(command);
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
                return true;
            }
        }
        catch(Exception ex)
        {
            Console.WriteLine("Unexpected Error, failure to write to database: "+ex);
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

    public bool UpdateQuestionaire()
    {
        throw new NotImplementedException();
    }
}