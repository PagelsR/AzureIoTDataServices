using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using System.Net.Http;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.IO;
using System.Text;
using System.Configuration;
using System.Reflection.Metadata;

namespace FunctionApps
{
    public static class HubwayCosmosDBTrigger
    {
        private static string AzureMapsSubscriptionKey = System.Environment.GetEnvironmentVariable("Azure_Maps_Subscription_Key");

        [FunctionName("HubwayCosmosDBTrigger")]
        public static async Task Run([CosmosDBTrigger(
            databaseName: "Hubway",
            containerName: "Tripdata",
            Connection = "Shared_Access_Key_DOCUMENTDB",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)]IReadOnlyList<Document> input, ILogger log)
        {
            string lat = null;
            string lon = null;

            foreach (var doc in input)
            {

                lat = doc.GetPropertyValue<string>("startStationLatitiude");
                lon = doc.GetPropertyValue<string>("startStationLongitude");

                log.LogInformation("Start Station Latitude variable lat: " + lat);
                log.LogInformation("Start Station Longitude variable lon: " + lon);

                // Create a New HttpClient object and dispose it when done, so the app doesn't leak resources
                using (HttpClient http = new HttpClient())

                    // Perform the Azure Map Search passing lat/lon
                    try
                    {

                        //var http = new HttpClient();
                        var url = string.Format("https://atlas.microsoft.com/search/address/reverse/json?subscription-key=" + AzureMapsSubscriptionKey = "&api-version=1.0&query=" + lat + "," + lon);

                        log.LogInformation("Formatted Map URL: " + url);

                        var response = await http.GetAsync(url);
                        var result = await response.Content.ReadAsStringAsync();

                        log.LogInformation("Azure Maps search result is: " + result);

                    }
                    catch (HttpRequestException e)
                    {
                        log.LogInformation("\nException Caught!");
                        log.LogInformation("Message :{0} ", e.Message);
                    }

            }

        }

    }

}