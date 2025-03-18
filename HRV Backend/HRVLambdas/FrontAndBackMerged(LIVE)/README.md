This is the current implementation of the backend Lambda. It is saved as FrontAndBackend lambda.
It is connected to the API gateway, and also uses Environment variables to fill in for the RDS Connection.

You can edit this code via Visual Studios.
To package, you would right click the project in visual studios, and publish. Ensure you change to linux x86, and zip contents from:
..\FrontAndBackMerged\FrontAndBackMerged\src\FrontAndBackMerged\bin\Release\net8.0\linux-x64

To call this live function, use the following curl command on windows CMD(But change the name and key to something that exists):

curl -X POST https://s0pex2wkse.execute-api.us-west-1.amazonaws.com/DefaultTests -H "Content-Type: application/json" -d "{\"body\":{\"RequestData\":{\"AuthInfo\":{\"AnonymizedID\":\"ValidName\",\"AccessKey\":\"ValidAccessKey\"},\"Type\":\"AddData\",\"CreationDate\":\"2025-01-21T00:00:00\",\"HRVInfo\":{\"SDNN\":10.5,\"RMSSD\":9.3,\"PNN50\":2.4,\"HeartBeats\":[70,72,68,74]},\"Flags\":{\"UserFlagged\":true,\"ProgramFlagged\":false},\"PersonalData\":{\"Age\":30,\"BMI\":24.5,\"HospitalName\":\"General Hospital\",\"Injury\":{\"Type\":\"Sprain\",\"Date\":\"2023-12-01T00:00:00\"}}}}}"

The above will call our API gateway url, which will then forward the information to the lambda. If the name and key are valid, we expect a true response.

I recommend you limit the perms for this via IAM to not be able to clear all data on the RDS, before deploying live.