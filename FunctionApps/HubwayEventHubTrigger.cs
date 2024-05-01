using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;

namespace FunctionApps
{
    public static class HubwayEventHubTrigger
    {
        // This function is triggered by an Event Hub named hubwaytelemetry.
        // It processes incoming messages from the Event Hub and writes them to a Cosmos DB database.
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
                // Deserialize the Event Hub message from a JSON String
                var messageData = JsonConvert.DeserializeObject<JObject>(myEventHubMessage);
                
                // Cosmos DB must have a unique id within its partition.
                string tempid = Guid.NewGuid().ToString();

                // Create the document to be written to Cosmos DB
                // Create a new anonymous object is created with properties that correspond to the expected schema of the Cosmos DB document. Each property is extracted from the JObject and converted to a string.
                outputDocument = new
                {
                    id = tempid,
                    tripduration = messageData["tripduration"]?.ToString(),
                    starttime = messageData["starttime"]?.ToString(),
                    stoptime = messageData["stoptime"]?.ToString(),
                    startstationid = messageData["startstationid"]?.ToString(),
                    startstationname = messageData["startstationname"]?.ToString(),
                    startstationlatitude = messageData["startstationlatitude"]?.ToString(),
                    startstationlongitude = messageData["startstationlongitude"]?.ToString(),
                    endstationid = messageData["endstationid"]?.ToString(),
                    endstationname = messageData["endstationname"]?.ToString(),
                    endstationlatitude = messageData["endstationlatitude"]?.ToString(),
                    endstationlongitude = messageData["endstationlongitude"]?.ToString(),
                    bikeid = messageData["bikeid"]?.ToString(),
                    usertype = messageData["usertype"]?.ToString(),
                    birthyear = messageData["birthyear"]?.ToString(),
                    gender = messageData["gender"]?.ToString()
                };

                // Serialize the document to a JSON string
                string outputDocumentJson = JsonConvert.SerializeObject(outputDocument);

                // Log the JSON string
                log.LogInformation($"Output document: {outputDocumentJson}");

            }
            catch (System.Exception ex)
            {
                log.LogError($"Error processing message: {ex.Message}");
                outputDocument = null;
            }

        }

    }
}
