using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.SignalRService;
using Microsoft.Extensions.Configuration;

using Microsoft.OpenApi.Models;
using System.Threading.Tasks;

using PizzaConf.Models;
using System.Net;
using Microsoft.AspNetCore.Mvc;

namespace PizzaConf.DeliveryTracker
{
    public class OrderTrackingFunction
    {
        IConfiguration _configuration;
        string _signalRConnectionString;

        public OrderTrackingFunction(IConfiguration configuration)
        {
            _configuration = configuration;
            _signalRConnectionString = _configuration["AzureSignalRConnectionString"];
        }

        [FunctionName("negotiate")]
        [OpenApiOperation(operationId:"negotiate", tags: new[] {"register with signalr"},Summary = "Register with SignalR")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(SignalRConnectionInfo), Description = "The OK response")]
        public SignalRConnectionInfo Negotiate(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            [SignalRConnectionInfo(HubName = "DeliveryInfo")] SignalRConnectionInfo connectionInfo)
        {
            return connectionInfo;
        }

        [FunctionName("trackorder")]
        [OpenApiOperation(operationId: "TrackOrder", tags: new[] { "track order" })]
        [OpenApiParameter(name: "orderId", In = ParameterLocation.Path, Required = true, Type = typeof(int), Description = "The order id to track")]
        [OpenApiParameter(name: "status", In = ParameterLocation.Path, Required = true, Type = typeof(int), Description = "New delivery status of the order")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(TrackingMessage), Description = "The OK response")]
        public async Task<IActionResult> TrackOrder(
           [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "{orderId:int}/{status:int}")] HttpRequest req, int orderId, int status,
           [SignalR(HubName = "DeliveryInfo")] IAsyncCollector<SignalRMessage> deliveryMessages)
        {
            string url;
            string statusText;

            switch (status)
            {
                case 1: 
                    url = "order1.jpg";
                    statusText = "Order received";
                    break;
                case 2:
                    url = "order2.jpg";
                    statusText = "Order being prepped";
                    break;
                case 3:
                    url = "order3.jpg";
                    statusText = "It's in the oven!";
                    break;
                default:
                    url = "order4.jpg";
                    statusText = "It's on it's way!";
                    break;
            }

            TrackingMessage msg = new() { StatusUrl = url, Status = statusText, OrderId = orderId };

            await deliveryMessages.AddAsync(new SignalRMessage
            {
                Target = "newMessage",
                Arguments = new[] { msg }
            });

            return new OkObjectResult(msg);
        }
    }
}