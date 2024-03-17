using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using static FunctionApps.HubwayCosmosDBTrigger;

namespace FunctionApps
{
    public static class HubwayCosmosDBTrigger_v2
    {
        [FunctionName("HubwayCosmosDBTrigger_v2")]
        public static async Task Run([CosmosDBTrigger(
            databaseName: "Hubway",
            containerName: "Tripdata",
            Connection = "Shared_Access_Key_DOCUMENTDB",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<TripData> input, ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
            }
        }
    }
}
