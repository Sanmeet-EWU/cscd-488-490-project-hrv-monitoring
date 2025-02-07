using Amazon.Lambda.Core;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]
namespace RDSConnection3306;

public class Function
{
    public async Task<string> FunctionHandler(string input)
    {
        // Aurora cluster endpoint (Replace with your actual cluster endpoint)
        string? host = Environment.GetEnvironmentVariable("host"); 
        string? databaseName = Environment.GetEnvironmentVariable("databaseName");
        string? username = Environment.GetEnvironmentVariable("username"); // Replace with your database username
        string? password = Environment.GetEnvironmentVariable("password"); // Replace with your database password
        string? connectionString = $"server={host};port=3306;user={username};password={password};database={databaseName}";
        var results = new List<List<string>>();

        try
        {
            // Create a connection to the Aurora database
            using (var connection = new MySqlConnection(connectionString))
            {
                // Open the connection
                await connection.OpenAsync();

                // Example query to select data
                string query = "SELECT * FROM SomeTable";

                using (var command = new MySqlCommand(query, connection))
                {
                    // Execute the query and read the results
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            // List to hold all column values for a single row
                            var row = new List<string>();

                            // Iterate over all columns in the current row and add their values to the row list
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                // Get the value of each column (use reader[i] for column index)
                                row.Add(reader[i]?.ToString() ?? "NULL"); // Handling null values safely
                            }

                            // Add the row (which is a list of column values) to the results list
                            results.Add(row);
                        }
                    }
                }

                // Close the connection
                connection.Close();
            }

            return JsonConvert.SerializeObject(results);
        }
        catch (Exception ex)
        {
            return $"Error: {ex.Message}";
        }
    }
}