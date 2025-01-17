using Amazon.Lambda.Core;
using System.Text.Json;
// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace HRVAuthorizationLambda
{
    public class AuthorizationFunction
    {

        /// <summary>
        /// A simple function that takes a string and returns both the upper and lower case version of the string.
        /// </summary>
        /// <param name="input">The event for the Lambda function handler to process.</param>
        /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
        /// <returns></returns>
        public bool FunctionHandler(string jsonString, ILambdaContext context)
        {
            // Deserialize the input string (assuming it's a JSON string)
            JsonDocument doc = JsonDocument.Parse(jsonString);
            JsonElement authData = doc.RootElement.GetProperty("RequestData").GetProperty("AuthInfo");
            string? AnonymizedID = authData.GetProperty("AnonymizedID").GetString();
            string? AccessKey = authData.GetProperty("AccessKey").GetString();

            bool result = false;
            //need to get pair from RDS with SQL query
            if (AnonymizedID == "ValidName" && AccessKey == "ValidAccessKey") 
                result = true;

            return result;
        }
    }
}