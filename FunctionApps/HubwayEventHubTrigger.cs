using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace FunctionApps
{
    public static class HubwayEventHubTrigger
    {
        [FunctionName("HubwayEventHubTrigger")]
        //public static async Task Run([EventHubTrigger("hubwaytelemetry", Connection = "Shared_Access_Key_EVENTHUB")] EventData[] events, ILogger log)
        public static Task Run([EventHubTrigger("hubwaytelemetry", Connection = "Shared_Access_Key_EVENTHUB", ConsumerGroup = "hubwaycg")] string myEventHubMessage, [CosmosDB(databaseName: "Hubway", "Tripdata", Connection = "Shared_Access_Key_DOCUMENTDB")] out dynamic outputDocument, ILogger log)

        {
            log.LogInformation($"C# Event Hub trigger function processed a message: {myEventHubMessage}");

            dynamic msg = JObject.Parse(myEventHubMessage);

            outputDocument = new
            {
                startTime = msg.GetValue("starttime").ToString(),
                stopTime = msg.GetValue("stoptime").ToString(),
                tripDuration = msg.GetValue("tripduration").ToString(),
                startStationID = msg.GetValue("start_station_id").ToString(),
                startStationName = msg.GetValue("start_station_name").ToString(),
                startStationLatitiude = msg.GetValue("start_station_latitude").ToString(),
                startStationLongitude = msg.GetValue("start_station_longitude").ToString(),
                endStationID = msg.GetValue("end_station_id").ToString(),
                endStationName = msg.GetValue("end_station_name").ToString(),
                endStationLatitude = msg.GetValue("end_station_latitude").ToString(),
                endStationLongitude = msg.GetValue("end_station_longitude").ToString(),
                bikeID = msg.GetValue("bikeid").ToString(),
                userType = msg.GetValue("usertype").ToString(),
                gender = msg.GetValue("gender").ToString()
            };

            //var exceptions = new List<Exception>();

            //foreach (EventData eventData in events)
            //{
            //    try
            //    {
            //        // Replace these two lines with your processing logic.
            //        log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");
            //        await Task.Yield();
            //    }
            //    catch (Exception e)
            //    {
            //        // We need to keep processing the rest of the batch - capture this exception and continue.
            //        // Also, consider capturing details of the message that failed processing so it can be processed again later.
            //        exceptions.Add(e);
            //    }
            //}

            //// Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            //if (exceptions.Count > 1)
            //    throw new AggregateException(exceptions);

            //if (exceptions.Count == 1)
            //    throw exceptions.Single();
        }
    }
}
