using HRVAuthorizationLambda;
using Microsoft.CodeCoverage.Core.Reports.Coverage;
using Mono.Cecil.Rocks;
using System.Reflection.Metadata;
using static HRVAuthorizationLambda.AuthorizationFunction;
namespace AuthorizorTests
{
    [TestClass]
    public sealed class LambdaTests
    {
        [TestMethod]
        public void Authorization_FromJsonString_ReturnsTrue()
        {
            //arrange
            string jsonString =
                "{\"RequestData\": {  \"AuthInfo\": { \"AnonymizedID\": \"ValidName\", \"AccessKey\": \"ValidAccessKey\" }}}";
            //act
            AuthorizationFunction f = new();
            bool returnVal =f.FunctionHandler(jsonString,null);
            //assert
            Assert.IsTrue(returnVal);
        }
    }
}