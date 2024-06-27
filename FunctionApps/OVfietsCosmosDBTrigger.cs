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
    public static class OVfietsCosmosDBTrigger
    {
        private static string AzureMapsSubscriptionKey = System.Environment.GetEnvironmentVariable("Azure_Maps_Subscription_Key");

        [FunctionName("OVfietsCosmosDBTrigger")]
        public static async Task Run([CosmosDBTrigger(
            databaseName: "ovfiets",
            containerName: "Tripdata",
            Connection = "Shared_Access_Key_DOCUMENTDB",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<TripData> input, ILogger log)
        {

            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified: " + input.Count);

                foreach (var tripData in input)
                {
                    // Access properties of the TripData class
                    log.LogInformation("Start Time: " + tripData.StartTime);
                    log.LogInformation("Stop Time: " + tripData.StopTime);

                    string lat = tripData.StartStationLatitude;
                    string lon = tripData.StartStationLongitude;

                    log.LogInformation("Start Station Latitude variable lat: " + tripData.StartStationLatitude);
                    log.LogInformation("Start Station Longitude variable lon: " + tripData.StartStationLongitude);

                    // Create a New HttpClient object and dispose it when done, so the app doesn't leak resources
                    using (HttpClient http = new HttpClient())

                    // Perform the Azure Map Search passing lat/lon
                    try
                    {

                        var url = $"https://atlas.microsoft.com/search/address/reverse/json?subscription-key={AzureMapsSubscriptionKey}&api-version=1.0&query={lat},{lon}";

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

        public class TripData
        {
            public string StartTime { get; set; }
            public string StopTime { get; set; }
            public string TripDuration { get; set; }
            public string StartStationID { get; set; }
            public string StartStationName { get; set; }
            public string StartStationLatitude { get; set; }
            public string StartStationLongitude { get; set; }
            public string EndStationID { get; set; }
            public string EndStationName { get; set; }
            public string EndStationLatitude { get; set; }
            public string EndStationLongitude { get; set; }
            public string BikeID { get; set; }
            public string UserType { get; set; }
            public string Gender { get; set; }
        }

    }

}
