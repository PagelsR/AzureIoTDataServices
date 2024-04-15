using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

public static class GetAzureMapsKey
{
    // C# Azure Function
    [FunctionName("GetAzureMapsKey")]
    public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
    {
        log.LogInformation("C# HTTP trigger function processed a request.");

        var mapsKey = Environment.GetEnvironmentVariable("Azure_Maps_Subscription_Key");

        log.LogInformation($"Retrieved MapsSubscriptionKey: {mapsKey}");

        return new OkObjectResult(mapsKey);
    }
}