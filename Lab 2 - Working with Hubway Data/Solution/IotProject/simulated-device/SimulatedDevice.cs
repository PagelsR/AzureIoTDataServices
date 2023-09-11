using System;
using Microsoft.Azure.Devices.Client;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Microsoft.Extensions.Configuration;
using ChoETL;
using System.Reflection;

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
            string s_connectionString = configuration.GetConnectionString("Shared_IoT_Hub_ConnnectionString");

            // Connect to the IoT hub using the MQTT protocol
            s_deviceClient = DeviceClient.CreateFromConnectionString(s_connectionString, TransportType.Mqtt);
            SendDeviceToCloudMessagesAsync();
            Console.ReadLine();
        }

        // Async method to send simulated telemetry
        private static async void SendDeviceToCloudMessagesAsync()
        {
            string dirPath = Path.GetFullPath(Directory.GetCurrentDirectory());
            string sFilePath = dirPath+"/data/201502-hubway-tripdata.csv";

            Console.WriteLine("******************************************************\n");
            Console.WriteLine( sFilePath );
            Console.WriteLine("******************************************************\n");

            var reader = new ChoCSVReader(sFilePath).WithFirstLineHeader();
            dynamic rec;
 
            while ((rec = reader.Read()) != null)
            {
                string json = Newtonsoft.Json.JsonConvert.SerializeObject(rec);

                var message = new Message(Encoding.ASCII.GetBytes(json));

                // Add a custom application property to the message.
                // An IoT hub can filter on these properties without access to the message body.
                message.Properties.Add("RoutingProperty", "Hubway");

                // Send the telemetry message
                await s_deviceClient.SendEventAsync(message);
                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, json);                

                await Task.Delay(500);
            }
        }

    }
}
