using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Xml.Linq;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace AuthLambda
{
    public class Function
    {
        /// <summary>
        /// A simple function that takes a string and returns both the upper and lower case version of the string.
        /// </summary>
        /// <param name="input">The event for the Lambda function handler to process.</param>
        /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
        /// <returns></returns>
        public bool FunctionHandler(APIGatewayHttpApiV2ProxyRequest request, ILambdaContext context)
        {

            string jsonString = request.Body;
            JsonDocument doc = JsonDocument.Parse(request.Body);
            var body = doc.RootElement.GetProperty("body").ToString();
            var bodyDoc = JsonDocument.Parse(body);

            var requestDataString = bodyDoc.RootElement.GetProperty("RequestData").ToString();
            var requestDataDoc = JsonDocument.Parse(requestDataString);


            var AuthInfoString = requestDataDoc.RootElement.GetProperty("AuthInfo").ToString();
            var AuthInfoDoc = JsonDocument.Parse(AuthInfoString);
            // Access the 'outerKey' object

            string? AnonymizedID = AuthInfoDoc.RootElement.GetProperty("AnonymizedID").GetString();
            string? AccessKey = AuthInfoDoc.RootElement.GetProperty("AccessKey").GetString();
            bool result = false;
            //need to get pair from RDS with SQL query
            if (AnonymizedID == "ValidName" && AccessKey == "ValidAccessKey")
                result = true;

            return result;
        }
    }
}