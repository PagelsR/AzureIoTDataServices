using System;
using Microsoft.Azure.Devices.Client;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Microsoft.Extensions.Configuration;
using ChoETL;
using System.Reflection;
//using Azure.Identity;
//using Azure.Security.KeyVault.Secrets;

namespace simulated_device
{
    class SimulatedDevice
    {
        private static DeviceClient s_deviceClient;

        private static void Main(string[] args)
        {
            Console.WriteLine("******************************************************\n");
            Console.WriteLine("Boston Hubway Data - Simulated device. Ctrl-C to exit.\n");
            Console.WriteLine("******************************************************\n");

            IConfigurationRoot configuration = new ConfigurationBuilder()
                .SetBasePath(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location))
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .Build();

            // Access the connection string
            string s_connectionString = configuration.GetConnectionString("SharedAccessKeyIOTHUB");

            // Create a new secret client using the default credential from Azure.Identity
            //var client = new SecretClient(new Uri("https://kv-kk57wcdfxcfco.vault.azure.net/"), new DefaultAzureCredential());

            // Retrieve the secret
            //KeyVaultSecret secret = client.GetSecret("SharedAccessKeyIOTHUB");

            // Access the connection string
            //string s_connectionString = secret.Value;

            Console.WriteLine("******************************************************\n");
            Console.WriteLine( s_connectionString );
            Console.WriteLine("******************************************************\n");

            // Connect to the IoT hub using the MQTT protocol
            s_deviceClient = DeviceClient.CreateFromConnectionString(s_connectionString, TransportType.Mqtt);

            // Get the maximum counter value from the command line arguments
            int maxCounterValue = args.Length > 0 ? int.Parse(args[0]) : 25;

            SendDeviceToCloudMessagesAsync(maxCounterValue);
            Console.ReadLine();
        }

        // Async method to send simulated telemetry
        private static async void SendDeviceToCloudMessagesAsync(int maxCounterValue)
        {
            string dirPath = Path.GetFullPath(Directory.GetCurrentDirectory());
            string sFilePath = dirPath+"/data/OV-fiets-2024-Utrecht-tripdata.csv";

            Console.WriteLine("******************************************************\n");
            Console.WriteLine( sFilePath );
            Console.WriteLine("******************************************************\n");

            var reader = new ChoCSVReader(sFilePath).WithFirstLineHeader();
            dynamic rec;
 
            int counter = 1;

            while ((rec = reader.Read()) != null && counter < maxCounterValue)
            {
                string json = Newtonsoft.Json.JsonConvert.SerializeObject(rec);

                var message = new Message(Encoding.ASCII.GetBytes(json));

                // Add a custom application property to the message.
                // An IoT hub can filter on these properties without access to the message body.
                message.Properties.Add("RoutingProperty", "Hubway");

                // Send the telemetry message
                await s_deviceClient.SendEventAsync(message);
                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, json);                
                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, message);                

                // Display the counter number per loop
                Console.WriteLine("Counter: {0}", counter);

                // Increment the counter
                counter++;

                await Task.Delay(100);

                // Write a blank line
                Console.WriteLine();
            }

            Environment.Exit(0);

        }

    }
}
