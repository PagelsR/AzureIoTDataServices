using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using CsvHelper;
using System.Collections.Generic;

public static class SendToIoTHub
{
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString("Shared_Access_Key_IOTHUB", TransportType.Mqtt);

    [FunctionName("SendToIoTHub")]
    public static async Task Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log)
    {
        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

        using (var reader = new StreamReader($"{Environment.GetEnvironmentVariable("GITHUB_WORKSPACE")}/simulated-device/data/201502-hubway-tripdata.csv"))
        using (var csv = new CsvReader(reader))
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

    private static async Task SendBatchToIoTHub(List<dynamic> records, ILogger log)
    {
        foreach (var record in records)
        {
            var messageString = Newtonsoft.Json.JsonConvert.SerializeObject(record);
            var message = new Message(Encoding.ASCII.GetBytes(messageString));

            await deviceClient.SendEventAsync(message);
            log.LogInformation($"Sent message: {messageString}");
        }
    }
}