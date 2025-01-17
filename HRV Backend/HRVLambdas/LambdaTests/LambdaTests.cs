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
        public void Authorization_ValidJsonValues_ReturnsTrue()
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

        [TestMethod]
        [DataRow("{\"RequestData\": {  \"AuthInfo\": { \"AnonymizedID\": \"InValidName\", \"AccessKey\": \"ValidAccessKey\" }}}")]
        [DataRow("{\"RequestData\": {  \"AuthInfo\": { \"AnonymizedID\": \"ValidName\", \"AccessKey\": \"InValidAccessKey\" }}}")]
        [DataRow("{\"RequestData\": {  \"AuthInfo\": { \"AnonymizedID\": \"InValidName\", \"AccessKey\": \"InValidAccessKey\" }}}")]
        public void Authorization_InvalidJsonValue_ReturnFalse(string JsonString)
        {
            //arrange
            //act
            AuthorizationFunction f = new();
            bool returnVal = f.FunctionHandler(JsonString, null);
            //assert
            Assert.IsFalse(returnVal);
        }
    }
}