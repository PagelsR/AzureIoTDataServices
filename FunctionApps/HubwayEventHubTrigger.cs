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
                    id = Guid.NewGuid().ToString();
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
