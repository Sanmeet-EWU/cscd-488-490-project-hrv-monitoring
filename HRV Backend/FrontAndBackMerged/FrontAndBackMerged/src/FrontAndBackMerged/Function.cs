using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Data;
using System.Text.Json;


[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace FrontAndBackMerged
{
    public class Function
    {
        private static MySqlConnection? Connection;
        private static APIGatewayHttpApiV2ProxyRequest? Request;
        private static string? RequestType;

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
                
                //bool executeRequest = ExecuteRequest();
                //if(!executeRequest) return 24;
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

                return (AnonymizedID, AccessKey);
            }
            catch
            {
                return (null, null);
            }
        }

        private static bool GetRequestType()
        {
            try
            {
                JsonDocument doc = JsonDocument.Parse(Request!.Body);
                var body = doc.RootElement.GetProperty("body").ToString();
                var bodyDoc = JsonDocument.Parse(body);
                var requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
                var requestDataDoc = JsonDocument.Parse(requestDataString);
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
            catch (Exception ex) {
                Console.WriteLine("Error when creating new user: "+ex);
                return "23";
            }
        }
    }

}