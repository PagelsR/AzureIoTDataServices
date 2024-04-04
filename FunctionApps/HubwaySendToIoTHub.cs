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

public static class SendToIoTHub
{
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString("Shared_Access_Key_IOTHUB", TransportType.Mqtt);

    // "SendToIoTHub" that is triggered every 5 minutes. Here's a step-by-step summary of what it does:
    // Logs the execution time of the function.
    // Opens a StreamReader to read a CSV file from a specified path.
    // Initializes a CsvReader to parse the CSV file.
    // Initializes a list to store the records from the CSV file and a counter to track the number of records.
    // Reads the CSV file line by line. For each line, it:
    // Gets the current record and adds it to the list.
    // Increments the counter.
    // If the counter reaches 500, it sends the batch of records to IoT Hub, then clears the list and resets the counter.
    // After reading all lines, if there are any remaining records in the list, it sends them to IoT Hub.

    [FunctionName("SendToIoTHub")]
    public static async Task Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log)
    {
        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

        try
        {
            using (var reader = new StreamReader($"{Environment.GetEnvironmentVariable("GITHUB_WORKSPACE")}/simulated-device/data/201502-hubway-tripdata.csv"))
            using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
            {
                var records = new List<dynamic>();
                int count = 0;

                while (csv.Read())
                {
                    var record = csv.GetRecord<dynamic>();
                    records.Add(record);
                    count++;

                    if (count == 500)
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

    /// <summary>
    /// Sends a batch of records to an IoT Hub.
    /// </summary>
    /// <param name="records">A list of records to be sent. Each record is a dynamic object.</param>
    /// <param name="log">An ILogger instance used for logging information about the sent messages.</param>
    /// <returns>A Task representing the asynchronous operation.</returns>
    private static async Task SendBatchToIoTHub(List<dynamic> records, ILogger log)
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
}