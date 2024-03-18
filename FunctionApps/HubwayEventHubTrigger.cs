using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System.Text.Json;
//using Newtonsoft.Json.Linq;

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
                JsonDocument msg = JsonDocument.Parse(myEventHubMessage);

                // Create the document to be written to Cosmos DB
                outputDocument = new
                // {
                //     startTime = msg.RootElement.GetProperty("starttime").GetString(),
                //     stopTime = msg.RootElement.GetProperty("stoptime").GetString(),
                //     tripDuration = msg.RootElement.GetProperty("tripduration").GetString(),
                //     startStationID = msg.RootElement.GetProperty("start station id").GetString(),
                //     startStationName = msg.RootElement.GetProperty("start station name").GetString(),
                //     startStationLatitiude = msg.RootElement.GetProperty("start station latitude").GetString(),
                //     startStationLongitude = msg.RootElement.GetProperty("start station longitude").GetString(),
                //     endStationID = msg.RootElement.GetProperty("end station id").GetString(),
                //     endStationName = msg.RootElement.GetProperty("end station name").GetString(),
                //     endStationLatitude = msg.RootElement.GetProperty("end station latitude").GetString(),
                //     endStationLongitude = msg.RootElement.GetProperty("end station longitude").GetString(),
                //     bikeID = msg.RootElement.GetProperty("bikeid").GetString(),
                //     userType = msg.RootElement.GetProperty("usertype").GetString(),
                //     gender = msg.RootElement.GetProperty("gender").GetString()
                // };

                {
                    startTime = msg.RootElement.TryGetProperty("starttime", out JsonElement startTimeElement) ? startTimeElement.GetString() : null,
                    stopTime = msg.RootElement.TryGetProperty("stoptime", out JsonElement stopTimeElement) ? stopTimeElement.GetString() : null,
                    tripDuration = msg.RootElement.TryGetProperty("tripduration", out JsonElement tripDurationElement) ? tripDurationElement.GetString() : null,
                    startStationID = msg.RootElement.TryGetProperty("start station id", out JsonElement startStationIDElement) ? startStationIDElement.GetString() : null,
                    startStationName = msg.RootElement.TryGetProperty("start station name", out JsonElement startStationNameElement) ? startStationNameElement.GetString() : null,
                    startStationLatitiude = msg.RootElement.TryGetProperty("start station latitude", out JsonElement startStationLatitiudeElement) ? startStationLatitiudeElement.GetString() : null,
                    startStationLongitude = msg.RootElement.TryGetProperty("start station longitude", out JsonElement startStationLongitudeElement) ? startStationLongitudeElement.GetString() : null,
                    endStationID = msg.RootElement.TryGetProperty("end station id", out JsonElement endStationIDElement) ? endStationIDElement.GetString() : null,
                    endStationName = msg.RootElement.TryGetProperty("end station name", out JsonElement endStationNameElement) ? endStationNameElement.GetString() : null,
                    endStationLatitude = msg.RootElement.TryGetProperty("end station latitude", out JsonElement endStationLatitudeElement) ? endStationLatitudeElement.GetString() : null,
                    endStationLongitude = msg.RootElement.TryGetProperty("end station longitude", out JsonElement endStationLongitudeElement) ? endStationLongitudeElement.GetString() : null,
                    bikeID = msg.RootElement.TryGetProperty("bikeid", out JsonElement bikeIDElement) ? bikeIDElement.GetString() : null,
                    userType = msg.RootElement.TryGetProperty("usertype", out JsonElement userTypeElement) ? userTypeElement.GetString() : null,
                    gender = msg.RootElement.TryGetProperty("gender", out JsonElement genderElement) ? genderElement.GetString() : null
                };
                
                // // Parse the Event Hub message from JSON
                // dynamic msg = JObject.Parse(myEventHubMessage);

                // // Create the document to be written to Cosmos DB
                // outputDocument = new
                // {
                //     startTime = msg.GetValue("starttime")?.ToString(),
                //     stopTime = msg.GetValue("stoptime")?.ToString(),
                //     tripDuration = msg.GetValue("tripduration")?.ToString(),
                //     startStationID = msg.GetValue("start_station_id")?.ToString(),
                //     startStationName = msg.GetValue("start_station_name")?.ToString(),
                //     startStationLatitiude = msg.GetValue("start_station_latitude")?.ToString(),
                //     startStationLongitude = msg.GetValue("start_station_longitude")?.ToString(),
                //     endStationID = msg.GetValue("end_station_id")?.ToString(),
                //     endStationName = msg.GetValue("end_station_name")?.ToString(),
                //     endStationLatitude = msg.GetValue("end_station_latitude")?.ToString(),
                //     endStationLongitude = msg.GetValue("end_station_longitude")?.ToString(),
                //     bikeID = msg.GetValue("bikeid")?.ToString(),
                //     userType = msg.GetValue("usertype")?.ToString(),
                //     gender = msg.GetValue("gender")?.ToString()
                // };

            }
            catch (System.Exception ex)
            {
                log.LogError($"Error processing message: {ex.Message}");
                outputDocument = null;
            }

        }

    }
}
