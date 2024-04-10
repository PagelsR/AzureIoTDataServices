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

public static class SimulatedIoTDevice_v3
{
    private static readonly DeviceClient deviceClient = DeviceClient.CreateFromConnectionString(Environment.GetEnvironmentVariable("Shared_Access_Key_IOTHUB"), TransportType.Mqtt);    

    [FunctionName("HubwaySendToIoTHubByCount")]
    public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
    {

        log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
        
        string recordCountStr = req.Query["recordCount"];
        int recordCount = string.IsNullOrEmpty(recordCountStr) ? 500 : int.Parse(recordCountStr);

        await SendDeviceToCloudMessagesAsync(recordCount, context, log);

        return new OkResult();
    }

    private static async Task SendDeviceToCloudMessagesAsync(int recordCount, ExecutionContext context, ILogger log)
    {
        log.LogInformation($"Starting to send {recordCount} records");

        int counter = 1;

        var config = new CsvHelper.Configuration.CsvConfiguration(CultureInfo.InvariantCulture)
            {
                HasHeaderRecord = true,
                Delimiter = ","
            };

        var sFilePath = Path.Combine(context.FunctionAppDirectory, "data", "201502-hubway-tripdata.csv");
        using (var reader = new StreamReader(sFilePath))
        using (var csv = new CsvReader(reader, config))
        {
            // csv.Configuration.HasHeaderRecord = true;
            // csv.Configuration.Delimiter = ",";
            var records = csv.GetRecords<dynamic>();
    
            //int counter = 1;
    
            foreach (var rec in records)
            {
                if (counter >= recordCount)
                    break;
    
                try
                {
                    string json = Newtonsoft.Json.JsonConvert.SerializeObject(rec);
    
                    var message = new Message(Encoding.ASCII.GetBytes(json));
    
                    message.Properties.Add("RoutingProperty", "Hubway");
    
                    await deviceClient.SendEventAsync(message);
    
                    counter++;
    
                    // Define messageString
                    string messageString = Encoding.ASCII.GetString(message.GetBytes());


                    // Log information about the sent message
                    log.LogInformation($"Sent message: {messageString}");
                }
                catch (Exception ex)
                {
                    // Log the exception
                    log.LogError($"An error occurred: {ex.Message}");
                }
            }

            log.LogInformation($"Success sending {counter} records");

        }
    }

}
