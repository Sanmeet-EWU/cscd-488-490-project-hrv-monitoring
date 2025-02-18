using Amazon.Lambda.APIGatewayEvents;
using AuthLambda;
using Newtonsoft.Json.Serialization;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace AuthLambdaTests
{
    [TestClass]
    public sealed class Test1
    {
    
        [TestMethod]
        public void AuthFunction_ValidJson_True()
        {
            //arrange

            string jsonString = @"
        {
          ""RequestData"": {
            ""AuthInfo"": {
              ""AnonymizedID"": ""ValidName"",
              ""AccessKey"": ""ValidAccessKey""
            },
            ""Type"": ""AddData"",
            ""CreationDate"": ""2025-01-21T00:00:00"",
            ""HRVInfo"": {
              ""SDNN"": 10.5,
              ""RMSSD"": 9.3,
              ""PNN50"": 2.4,
              ""HeartBeats"": [70, 72, 68, 74]
            },
            ""Flags"": {
              ""UserFlagged"": true,
              ""ProgramFlagged"": false
            },
            ""PersonalData"": {
              ""Age"": 30,
              ""BMI"": 24.5,
              ""HospitalName"": ""General Hospital"",
              ""Injury"": {
                ""Type"": ""Sprain"",
                ""Date"": ""2023-12-01T00:00:00""
              }
            }
          }
        }";
            APIGatewayHttpApiV2ProxyRequest request = new APIGatewayHttpApiV2ProxyRequest
            {
                Body = JsonSerializer.Serialize(new { body = jsonString }),
            };

            //act
            Function f = new();
            bool result =f.FunctionHandler(request, null);
            //assert
            Assert.IsTrue(result);
        }

        [TestMethod]
    
        public void AuthFunction_InValidName_False()
        {

            //Arrange
            string jsonString = @"
        {
          ""RequestData"": {
            ""AuthInfo"": {
              ""AnonymizedID"": ""InvalidName"",
              ""AccessKey"": ""ValidAccessKey""
            },
            ""Type"": ""AddData"",
            ""CreationDate"": ""2025-01-21T00:00:00"",
            ""HRVInfo"": {
              ""SDNN"": 10.5,
              ""RMSSD"": 9.3,
              ""PNN50"": 2.4,
              ""HeartBeats"": [70, 72, 68, 74]
            },
            ""Flags"": {
              ""UserFlagged"": true,
              ""ProgramFlagged"": false
            },
            ""PersonalData"": {
              ""Age"": 30,
              ""BMI"": 24.5,
              ""HospitalName"": ""General Hospital"",
              ""Injury"": {
                ""Type"": ""Sprain"",
                ""Date"": ""2023-12-01T00:00:00""
              }
            }
          }
        }";
            APIGatewayHttpApiV2ProxyRequest request = new APIGatewayHttpApiV2ProxyRequest
            {
                Body = JsonSerializer.Serialize(new { body = jsonString }),
            };

            //act
            Function f = new();
            bool result = f.FunctionHandler(request, null);
            //assert
            Assert.IsFalse(result);

        }

        [TestMethod]
        public void AuthFunction_InValidAccessKey_False()
        {

            //Arrange
            string jsonString = @"
        {
          ""RequestData"": {
            ""AuthInfo"": {
              ""AnonymizedID"": ""InvalidName"",
              ""AccessKey"": ""InValidAccessKey""
            },
            ""Type"": ""AddData"",
            ""CreationDate"": ""2025-01-21T00:00:00"",
            ""HRVInfo"": {
              ""SDNN"": 10.5,
              ""RMSSD"": 9.3,
              ""PNN50"": 2.4,
              ""HeartBeats"": [70, 72, 68, 74]
            },
            ""Flags"": {
              ""UserFlagged"": true,
              ""ProgramFlagged"": false
            },
            ""PersonalData"": {
              ""Age"": 30,
              ""BMI"": 24.5,
              ""HospitalName"": ""General Hospital"",
              ""Injury"": {
                ""Type"": ""Sprain"",
                ""Date"": ""2023-12-01T00:00:00""
              }
            }
          }
        }";
            APIGatewayHttpApiV2ProxyRequest request = new APIGatewayHttpApiV2ProxyRequest
            {
                Body = JsonSerializer.Serialize(new { body = jsonString }),
            };

            //act
            Function f = new();
            bool result = f.FunctionHandler(request, null);
            //assert
            Assert.IsFalse(result);

        }


    }
}
