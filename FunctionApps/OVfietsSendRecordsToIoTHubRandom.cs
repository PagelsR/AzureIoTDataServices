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
using System.Linq;

// This class simulates an IoT device sending data to Azure IoT Hub.
public static class SimulatedIoTDeviceRandom
{
    // Create a device client using the connection string from the environment variable.
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB"), TransportType.Mqtt);    

    // Define the random variable
    private static readonly Random random = new Random();
    
    // This function is triggered by an HTTP request.
    [FunctionName("OVfietsSendRecordsToIoTHubRandom")]
    public static async Task Run(
            [TimerTrigger("0 0 */3 * * *")] TimerInfo myTimer, ILogger log, ExecutionContext context)
    {
        // Log the execution time of the function.
        log.LogInformation($"C# HTTP trigger function executed at: {DateTime.Now}");
        
        log.LogInformation($"Shared_Access_Key_IOTHUB: {Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB")}");

        // Get the record count from the query string or default to 600.
        // string recordCountStr = req.Query["recordCount"];

        // Randomly select a number between 200 and 800
        int recordCount = random.Next(200, 801); 

        // Log the start of the record sending process.
        log.LogInformation($"Attempting to send {recordCount} data items to IoT Hub...");

        // Counter for the number of records sent.
        int counter = 0;

        // Configure the CSV reader.
        var config = new CsvHelper.Configuration.CsvConfiguration(CultureInfo.InvariantCulture)
        {
            HasHeaderRecord = true,
            Delimiter = ","
        };

        // Path to the CSV file.
        var sFilePath = Path.Combine(context.FunctionAppDirectory, "data", "2024-OVFiets-Utrecht-tripdata.csv");
        using (var reader = new StreamReader(sFilePath))
        using (var csv = new CsvReader(reader, config))
        {
            // Get the records from the CSV file.
            //var records = csv.GetRecords<dynamic>();
            var records = csv.GetRecords<dynamic>().ToList();
            var random = new Random();
            var selectedRecords = records.OrderBy(x => random.Next()).Take(recordCount);
    
            // Send each record to the IoT Hub.
            foreach (var rec in selectedRecords)
            {
                try
                {
                    string json = Newtonsoft.Json.JsonConvert.SerializeObject(rec);
                    byte[] messageBody = Encoding.ASCII.GetBytes(json);
                            
                    using (var stream = new MemoryStream(messageBody))
                    {
                        var message = new Message(stream);
                        message.Properties.Add("RoutingProperty", "OVfiets");
                        await deviceClient.SendEventAsync(message);

                        counter++;
                        string messageString = Encoding.ASCII.GetString(messageBody);
                        log.LogInformation($"Sent message: {messageString}");
                    }
                }
                catch (Exception ex)
                {
                    log.LogError($"An error occurred: {ex.Message}");
                }
            }

            // Log the success of the record sending process.
            log.LogInformation($"Success sending {counter} records");
        }

        // Return a success message.
        string resultMessage = $"{recordCount} random records sent to IoT Hub.";
        //return new OkObjectResult(resultMessage);
        log.LogInformation(resultMessage);
    }
}