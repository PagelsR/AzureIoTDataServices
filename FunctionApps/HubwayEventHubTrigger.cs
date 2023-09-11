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
        public static void Run([EventHubTrigger("hubwaytelemetry", 
            Connection = "Shared_Access_Key_EVENTHUB", 
            ConsumerGroup = "hubwaycg")] string myEventHubMessage, 
            [CosmosDB(databaseName: "Hubway", containerName: "Tripdata", 
            Connection = "Shared_Access_Key_DOCUMENTDB")] out dynamic outputDocument, ILogger log)

        {
            log.LogInformation($"C# Event Hub trigger function processed a message: {myEventHubMessage}");

            try
            {
                // Parse the Event Hub message from JSON
                dynamic msg = JObject.Parse(myEventHubMessage);

                // Create the document to be written to Cosmos DB
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

            }
            catch (System.Exception ex)
            {
                log.LogError($"Error processing message: {ex.Message}");
                outputDocument = null;
            }

        }

    }
}
