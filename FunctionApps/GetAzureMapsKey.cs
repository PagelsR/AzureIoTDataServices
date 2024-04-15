// C# Azure Function
[FunctionName("GetAzureMapsKey")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
    ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    var mapsKey = Environment.GetEnvironmentVariable("Azure_Maps_Subscription_Key");

    log.LogInformation($"Retrieved MapsSubscriptionKey: {mapsKey}");

    return new OkObjectResult(mapsKey);
}