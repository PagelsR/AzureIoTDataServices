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

public static class SimulatedIoTDevice
{
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB"), TransportType.Mqtt);    

    // The SimulatedIoTDevice function is an Azure Function that gets triggered by
    // an HTTP request. It reads a CSV file, processes records ...
    [FunctionName("SimulatedIoTDevice")]
    public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
    {
        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

        string batchSizeStr = req.Query["batchSize"];
        int batchSize = string.IsNullOrEmpty(batchSizeStr) ? 3000 : int.Parse(batchSizeStr);

        log.LogInformation($"Attempting to send {batchSize} data items to IoT Hub...");

        IActionResult preTryResult = new OkObjectResult($"Attempting to send {batchSize} data items to IoT Hub...");

        try
        {
            var csvFilePath = Path.Combine(context.FunctionAppDirectory, "data", "201502-hubway-tripdata.csv");
            using (var reader = new StreamReader(csvFilePath))
            using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
            {
                var records = new List<dynamic>();
                int count = 0;

                while (csv.Read())
                {
                    var record = csv.GetRecord<dynamic>();
                    records.Add(record);
                    count++;

                    if (count == batchSize)
                    {
                        await SendBatchToIoTHub(records, log);
                        records.Clear();
                        count = 0;
                    }
                }

                if (records.Count > 0)
                {
                    await SendBatchToIoTHub(records, log);
                }
            }

            //return new OkObjectResult("Data sent to IoT Hub successfully");
        }
        catch (Exception ex)
        {
            log.LogError($"An error occurred: {ex.Message}");
            log.LogError(ex.StackTrace);
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);
        }

        IActionResult postTryResult = new OkObjectResult($"Success!!! A batch of {batchSize.ToString("N0")} data items sent to IoT Hub successfully. Thank you!");

        return postTryResult;

    }

    private static async Task SendBatchToIoTHub(List<dynamic> records, ILogger log)
    {
        try
        {
            // Iterate over each record in the list
            foreach (var record in records)
            {
                // Serialize the record into a JSON string
                var messageString = Newtonsoft.Json.JsonConvert.SerializeObject(record);

                // Convert the JSON string to a byte array and create a new Message object
                var message = new Message(Encoding.ASCII.GetBytes(messageString));

                // Add a custom application property to the message.
                // An IoT hub can filter on these properties without access to the message body.
                message.Properties.Add("RoutingProperty", "Hubway");

                // Send the Message object to the IoT Hub
                await deviceClient.SendEventAsync(message);

                // Log information about the sent message
                log.LogInformation($"Sent message: {messageString}");

            }
        }
        catch (Exception ex)
        {
            // Log the exception details
            log.LogError($"An error occurred: {ex.Message}. StackTrace: {ex.StackTrace}");
        }
    }
}