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
    public static class HubwayHttpTrigger
    {
        [FunctionName("HubwayHttpTrigger")]
        //public static IActionResult Run(
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

            // Log the first 5 items in the list
            // foreach (var tripItem in tripItems.Take(5))
            // {
            //     log.LogInformation($"Trip Item: {JsonConvert.SerializeObject(tripItem)}");
            // }

            // based on http://geojson.org/
            // https://tools.ietf.org/html/rfc7946#section-1.3

            // return GeoJson object
            TripDataGeoJson tdGeoJson = new TripDataGeoJson();

            // create the list of features            
            tdGeoJson.features = new List<LocalFeatures>();

            LocalFeatures myFeatures = null;

            string sStartStationName = null;
            double dStartStationLatitude = 0.0;
            double dStartStationLongitude = 0.0;

            string sCurrentStationID = null;
            string sLastStationID = null;
            int iCounter = 1;

            try
            {
                // process each item in the list
                foreach (var doc in tripItems)
                {
                    // grab the stationID from the list
                    sCurrentStationID = doc.startStationID;

                    log.LogInformation($"C# HTTP trigger function processed a request. Current Station ID: {sCurrentStationID}");

                    //compare station ID's
                    if (sCurrentStationID == sLastStationID)
                    {
                        // they are in the same array
                        log.LogInformation("Station id's match: "+ sCurrentStationID );

                        // increment the counter
                        iCounter += 1;
                    }
                    else
                    {
                        // they do not match
                        log.LogInformation($"Station id's do NOT match: {sCurrentStationID}");

                        // create the Properties object
                        Properties prop = new Properties();
                        prop.numberOfStations = iCounter;
                        prop.startStationID = sLastStationID;
                        prop.startStationName = sStartStationName;

                        LocalGeometry geo = new LocalGeometry();
                        geo.coordinates = new List<double>();
                        geo.coordinates.Add(dStartStationLongitude);
                        geo.coordinates.Add(dStartStationLatitude);

                        myFeatures = new LocalFeatures();
                        myFeatures.properties = prop;
                        myFeatures.geometry = geo;

                        tdGeoJson.features.Add(myFeatures);

                        // reset the counter
                        iCounter = 1;

                    }

                    // set for comparison
                    sLastStationID = doc.startStationID;
                    sStartStationName = doc.startStationName;
                    dStartStationLatitude = Convert.ToDouble(doc.startStationLatitude);
                    dStartStationLongitude = Convert.ToDouble(doc.startStationLongitude);
                    // dStartStationLatitude = doc.startStationLatitude;
                    // dStartStationLongitude = doc.startStationLongitude;

                }
            }
            catch (Exception ex)
            {
                log.LogInformation("Exception: " + ex.Message);
            }

            // remove the first record -- null references first time thru loop
            tdGeoJson.features.RemoveAt(0);

            return tdGeoJson;
        }

        public class TripItems
        {

            public string startStationID { get; set; }
            public string startStationName { get; set; }

            public string startStationLatitude { get; set; }

            public string startStationLongitude { get; set; }
            // public double startStationLatitude { get; set; }

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
