This authorization lambda takes in a specific json format (seen in the tests) and returns true or false based on the name of the function.

To call this live function, use the following curl command on windows CMD:

curl -X POST https://s0pex2wkse.execute-api.us-west-1.amazonaws.com/DefaultTests -H "Content-Type: application/json" -d "{\"body\":{\"RequestData\":{\"AuthInfo\":{\"AnonymizedID\":\"ValidName\",\"AccessKey\":\"ValidAccessKey\"},\"Type\":\"AddData\",\"CreationDate\":\"2025-01-21T00:00:00\",\"HRVInfo\":{\"SDNN\":10.5,\"RMSSD\":9.3,\"PNN50\":2.4,\"HeartBeats\":[70,72,68,74]},\"Flags\":{\"UserFlagged\":true,\"ProgramFlagged\":false},\"PersonalData\":{\"Age\":30,\"BMI\":24.5,\"HospitalName\":\"General Hospital\",\"Injury\":{\"Type\":\"Sprain\",\"Date\":\"2023-12-01T00:00:00\"}}}}}"

The above will call our API gateway url, which will then forward the information to the lambda. If the name and key are valid, we expect a true response.