using System;
using Azure.Identity;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(PizzaConf.DeliveryTracker.Startup))]

namespace PizzaConf.DeliveryTracker;

class Startup : FunctionsStartup
{
    public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
    {
        string cs = Environment.GetEnvironmentVariable("appConfigUrl");
        builder.ConfigurationBuilder.AddAzureAppConfiguration((options) =>
        {
            options.Connect(new Uri(cs), new DefaultAzureCredential())
                .ConfigureKeyVault(kvOptions => kvOptions.SetCredential(new DefaultAzureCredential()));
        });
    }

    public override void Configure(IFunctionsHostBuilder builder)
    {
    }
}