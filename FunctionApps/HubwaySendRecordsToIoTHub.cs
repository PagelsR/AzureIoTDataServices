using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using CsvHelper;
using System.Collections.Generic;
using System.Globalization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

// This class simulates an IoT device sending data to Azure IoT Hub.
public static class SimulatedIoTDevice
{
    // Create a device client using the connection string from the environment variable.
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB"), TransportType.Mqtt);    

    // This function is triggered by an HTTP request.
    [FunctionName("HubwaySendRecordsToIoTHub")]
    public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
    {
        // Log the execution time of the function.
        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
        
        // Get the record count from the query string or default to 550.
        string recordCountStr = req.Query["recordCount"];
        int recordCount = string.IsNullOrEmpty(recordCountStr) ? 550 : int.Parse(recordCountStr);

        // Log the start of the record sending process.
        log.LogInformation($"Attempting to send {recordCount} data items to IoT Hub...");

        // Counter for the number of records sent.
        int counter = 1;

        // Configure the CSV reader.
        var config = new CsvHelper.Configuration.CsvConfiguration(CultureInfo.InvariantCulture)
        {
            HasHeaderRecord = true,
            Delimiter = ","
        };

        // Path to the CSV file.
        var sFilePath = Path.Combine(context.FunctionAppDirectory, "data", "201502-hubway-tripdata.csv");
        using (var reader = new StreamReader(sFilePath))
        using (var csv = new CsvReader(reader, config))
        {
            // Get the records from the CSV file.
            var records = csv.GetRecords<dynamic>();
    
            // Send each record to the IoT Hub.
            foreach (var rec in records)
            {
                // Stop sending records if the record count is reached.
                if (counter >= recordCount)
                    break;
    
                try
                {
                    // Convert the record to JSON.
                    string json = Newtonsoft.Json.JsonConvert.SerializeObject(rec);

                    // Convert the JSON to a byte array.
                    byte[] messageBody = Encoding.ASCII.GetBytes(json);
                            
                    // Convert the byte array to a stream.
                    using (var stream = new MemoryStream(messageBody))
                    {
                        // Create a message from the stream.
                        var message = new Message(stream);

                        // Add a property to the message.
                        message.Properties.Add("RoutingProperty", "Hubway");

                        // Send the message to the IoT Hub.
                        await deviceClient.SendEventAsync(message);

                        // Increment the counter.
                        counter++;

                        // Log the sent message.
                        string messageString = Encoding.ASCII.GetString(messageBody);
                        log.LogInformation($"Sent message: {messageString}");
                    }
                }
                catch (Exception ex)
                {
                    // Log any exceptions.
                    log.LogError($"An error occurred: {ex.Message}");
                }
            }

            // Log the success of the record sending process.
            log.LogInformation($"Success sending {counter} records");
        }

        // Return a success message.
        string resultMessage = $"{recordCount} records sent to IoT Hub.";
        return new OkObjectResult(resultMessage);
    }
}