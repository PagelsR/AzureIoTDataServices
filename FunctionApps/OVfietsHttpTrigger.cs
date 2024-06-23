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
    public static class OVfietsHttpTrigger
    {
        // The function retrieves data from a CosmosDB database
        // and processes it to generate a GeoJSON object.
        [FunctionName("OVfietsHttpTrigger")]
        public static TripDataGeoJson Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
        [CosmosDB(databaseName: "OVfiets",
                containerName: "Tripdata",
                Connection = "Shared_Access_Key_DOCUMENTDB",
                SqlQuery = "SELECT * FROM c order by c.startStationID")]
                IEnumerable<TripItems> tripItems,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            // Initialize GeoJson object
            // GeoJSON is a format for encoding a variety of
            // geographic data structures. 
            TripDataGeoJson tdGeoJson = new TripDataGeoJson
            {
                features = new List<LocalFeatures>()
            };

            // Group tripItems by startStationID
            var groupedTripItems = tripItems.GroupBy(t => t.startStationID);

            // Log the groupedTripItems
            log.LogInformation($"groupedTripItems: {JsonConvert.SerializeObject(groupedTripItems)}");

            // Loop through each group in the groupedTripItems collection
            foreach (var group in groupedTripItems)
            {
                // Get the first item in the current group
                var firstItem = group.First();
            
                // Create a new Properties object with the number of stations in the group,
                // the ID of the start station (which is the key of the group),
                // and the name of the start station.
                Properties prop = new Properties
                {
                    numberOfStations = group.Count(),
                    startStationID = group.Key,
                    startStationName = firstItem.startStationName
                };
            
                // Create a new LocalGeometry object with the
                // longitude and latitude of the start station
                LocalGeometry geo = new LocalGeometry
                {
                    coordinates = new List<double>
                    {
                        firstItem.startStationLongitude,
                        firstItem.startStationLatitude
                    }
                };
            
                // Create a new LocalFeatures object with the previously
                // created Properties and LocalGeometry objects,
                // and add it to the features list of the tdGeoJson object
                tdGeoJson.features.Add(new LocalFeatures
                {
                    properties = prop,
                    geometry = geo
                });
            }
            
            // Return the tdGeoJson object, which now contains a list of
            // LocalFeatures objects, each representing a group of trip items

            // This GeoJSON object can be used to visualize the trip data on a map,
            // as GeoJSON is a standard format for encoding geographic data that
            // can be rendered by mapping and GIS software.

           return tdGeoJson;
        }

        public class TripItems
        {
            public string startStationID { get; set; }
            public string startStationName { get; set; }
            public double startStationLatitude { get; set; }
            public double startStationLongitude { get; set; }
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
