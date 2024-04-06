using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using CsvHelper;
using System.Collections.Generic;
using System.Globalization;
using Microsoft.AspNetCore.Http;

public static class SimulatedIoTDevice
{
    // private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString("Shared_Access_Key_IOTHUB", TransportType.Mqtt);
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB"), TransportType.Mqtt);    

    // The SimulatedIoTDevice function is an Azure Function that gets triggered by
    // an HTTP request. It reads a CSV file, processes records in batches,
    // and sends each batch to an IoT Hub. The batch size is specified by a
    // query parameter batchSize, defaulting to 3000 if not provided.
    //
    // Example URL to call the function with a batch size of 5000:
    // https://<APP_NAME>.azurewebsites.net/api/SimulatedIoTDevice?batchSize=5000
    [FunctionName("SimulatedIoTDevice")]
    public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req, 
    ILogger log, ExecutionContext context)
    {
        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

        string batchSizeStr = req.Query["batchSize"];
        int batchSize = string.IsNullOrEmpty(batchSizeStr) ? 3000 : int.Parse(batchSizeStr);

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
        }
        catch (Exception ex)
        {
            log.LogError($"An error occurred: {ex.Message}");
            log.LogError(ex.StackTrace);
        }
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