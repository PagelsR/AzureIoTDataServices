using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using Newtonsoft.Json;
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
                //JsonDocument msg = JsonDocument.Parse(myEventHubMessage);
                // Parse the incoming message
                var messageData = JsonConvert.DeserializeObject<JObject>(myEventHubMessage);

                // Create the document to be written to Cosmos DB
                outputDocument = new
                {
                    startTime = messageData["\"starttime\""]?.ToString(),
                    stopTime = messageData["\"stoptime\""]?.ToString(),
                    tripDuration = messageData["\"tripduration\""]?.ToString(),
                    startStationID = messageData["\"start station id\""]?.ToString(),
                    startStationName = messageData["\"start station name\""]?.ToString(),
                    startStationLatitiude = messageData["\"start station latitude\""]?.ToString(),
                    startStationLongitude = messageData["\"start station longitude\""]?.ToString(),
                    endStationID = messageData["\"end station id\""]?.ToString(),
                    endStationName = messageData["\"end station name\""]?.ToString(),
                    endStationLatitude = messageData["\"end station latitude\""]?.ToString(),
                    endStationLongitude = messageData["\"end station longitude\""]?.ToString(),
                    bikeID = messageData["\"bikeid\""]?.ToString(),
                    userType = messageData["\"usertype\""]?.ToString(),
                    gender = messageData["\"gender\""]?.ToString()
                };

                // startTime = messageData["startTime"]?.ToString(), // Safe navigation in case of null
                // stopTime = messageData["stopTime"]?.ToString(),
                // tripDuration = messageData["tripDuration"]?.ToString(),
                // startStationID = messageData["start_station_id"]?.ToString(),
                // startStationName = messageData["start_station_name"]?.ToString(),
                // startStationLatitiude = messageData["start_station_latitude"]?.ToString(),
                // startStationLongitude = messageData["start_station_longitude"]?.ToString(),
                // endStationID = messageData["end_station_id"]?.ToString(),
                // endStationName = messageData["end_station_name"]?.ToString(),
                // endStationLatitude = messageData["end_station_latitude"]?.ToString(),
                // endStationLongitude = messageData["end_station_longitude"]?.ToString(),
                // bikeID = messageData["bikeid"]?.ToString(),
                // userType = messageData["usertype"]?.ToString(),
                // gender = messageData["gender"]?.ToString()

                // Serialize the document to a JSON string
                string outputDocumentJson = JsonConvert.SerializeObject(outputDocument);

                // Log the JSON string
                log.LogInformation($"Output document: {outputDocumentJson}");

                // messageData.TryGetValue("starttime", out object startTime);
                // messageData.TryGetValue("stoptime", out object stopTime);
                // messageData.TryGetValue("tripduration", out object tripDuration);
                // messageData.TryGetValue("start_station_id", out object startStationID);
                // messageData.TryGetValue("start_station_name", out object startStationName);
                // messageData.TryGetValue("start_station_latitude", out object startStationLatitude);
                // messageData.TryGetValue("start_station_longitude", out object startStationLongitude);
                // messageData.TryGetValue("end_station_id", out object endStationID);
                // messageData.TryGetValue("end_station_name", out object endStationName);
                // messageData.TryGetValue("end_station_latitude", out object endStationLatitude);
                // messageData.TryGetValue("end_station_longitude", out object endStationLongitude);
                // messageData.TryGetValue("bikeid", out object bikeID);
                // messageData.TryGetValue("usertype", out object userType);
                // messageData.TryGetValue("gender", out object gender);

                // outputDocument = new
                // {
                //     startTime = startTime?.ToString(),
                //     stopTime = stopTime?.ToString(),
                //     tripDuration = tripDuration?.ToString(),
                //     startStationID = startStationID?.ToString(),
                //     startStationName = startStationName?.ToString(),
                //     startStationLatitude = startStationLatitude?.ToString(),
                //     startStationLongitude = startStationLongitude?.ToString(),
                //     endStationID = endStationID?.ToString(),
                //     endStationName = endStationName?.ToString(),
                //     endStationLatitude = endStationLatitude?.ToString(),
                //     endStationLongitude = endStationLongitude?.ToString(),
                //     bikeID = bikeID?.ToString(),
                //     userType = userType?.ToString(),
                //     gender = gender?.ToString()
                // };


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
