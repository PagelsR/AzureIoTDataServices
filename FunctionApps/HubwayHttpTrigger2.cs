using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace FunctionApps
{
    public static class HubwayHttpTrigger2
    {
        [FunctionName("HubwayHttpTrigger2")]
        public static TripDataGeoJson Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
        [CosmosDB(databaseName: "Hubway",
                containerName: "Tripdata",
                Connection = "Shared_Access_Key_DOCUMENTDB",
                SqlQuery = "SELECT * FROM c order by c.startStationID")]
                IEnumerable<TripItems> tripItems,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            // Initialize GeoJson object
            TripDataGeoJson tdGeoJson = new TripDataGeoJson
            {
                features = new List<LocalFeatures>()
            };

            // Group tripItems by startStationID
            var groupedTripItems = tripItems.GroupBy(t => t.startStationID);

            // Process each group
            foreach (var group in groupedTripItems)
            {
                var firstItem = group.First();

                // Create Properties object
                Properties prop = new Properties
                {
                    numberOfStations = group.Count(),
                    startStationID = group.Key,
                    startStationName = firstItem.startStationName
                };

                // Create LocalGeometry object
                LocalGeometry geo = new LocalGeometry
                {
                    coordinates = new List<double>
                    {
                        Convert.ToDouble(firstItem.startStationLongitude),
                        Convert.ToDouble(firstItem.startStationLatitiude)
                    }
                };

                // Create LocalFeatures object and add to features list
                tdGeoJson.features.Add(new LocalFeatures
                {
                    properties = prop,
                    geometry = geo
                });
            }

            return tdGeoJson;
        }

        public class TripItems
        {

            public string startStationID { get; set; }
            public string startStationName { get; set; }

            public string startStationLatitiude { get; set; }

            public string startStationLongitude { get; set; }
            // public double startStationLatitiude { get; set; }

            // public double startStationLongitude { get; set; }
        }

        public class LocalGeometry
        {
            private string _type = "Point";

            public string type
            {
                get { return _type; }
            }
            public List<double> coordinates { get; set; }
        }

        public class Properties
        {
            public int numberOfStations { get; set; }

            public string startStationID { get; set; }
            public string startStationName { get; set; }
        }

        public class LocalFeatures
        {
            private string _type = "Feature";

            public string type
            {
                get { return _type; }
            }
            public Properties properties { get; set; }
            public LocalGeometry geometry { get; set; }

        }

        public class TripDataGeoJson
        {
            private string _type = "FeatureCollection";

            public string type
            {
                get { return _type; }
            }
            public List<LocalFeatures> features { get; set; }
        }

    }
}
