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
        string appConfigUrl = Environment.GetEnvironmentVariable("appConfigUrl") ?? "";

        if (string.IsNullOrEmpty(appConfigUrl))
            throw new NullReferenceException($"{nameof(appConfigUrl)} setting needs to be set to the Azure App Config url");

        builder.ConfigurationBuilder.AddAzureAppConfiguration((options) =>
        {
            options.Connect(new Uri(appConfigUrl), new DefaultAzureCredential())
                .ConfigureKeyVault(kvOptions => kvOptions.SetCredential(new DefaultAzureCredential()));
        });
    }

    public override void Configure(IFunctionsHostBuilder builder)
    {
    }
}