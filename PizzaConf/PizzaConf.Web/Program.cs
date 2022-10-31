using Azure.Identity;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using PizzaConf.Web.Data;

using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using PizzaConf.Web.Configuration;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<PizzaWebService>();
builder.Services.AddSingleton<CartWebService>();

builder.Configuration.AddAzureAppConfiguration((options) =>
{
    // Make sure it doesn't blow up because it doesn't have access to key vault
    options.Connect(new Uri(builder.Configuration["appConfigUrl"]), new DefaultAzureCredential())
        .Select("cartUrl").Select("menuUrl").Select("trackingUrl").Select("DaprAppId*");
});

var daprIds = builder.Configuration.GetSection("DaprAppId:PizzaConf").Get<DaprAppId>();

builder.Services.AddHttpClient<PizzaWebService>(client =>
{
    Uri baseAddress;

    if (!string.IsNullOrEmpty(daprIds?.MenuApi))
    {
        baseAddress = new Uri("http://localhost:3602");
        client.DefaultRequestHeaders.Add("dapr-app-id", daprIds.MenuApi);
    }
    else
    {
        baseAddress = new Uri(builder.Configuration["menuUrl"]);
    }

    client.BaseAddress = baseAddress;
});

builder.Services.AddHttpClient<CartWebService>(client =>
{
    Uri baseAddress;

    if (!string.IsNullOrEmpty(daprIds?.CheckoutApi))
    {
        baseAddress = new Uri("http://localhost:3602");
        client.DefaultRequestHeaders.Add("dapr-app-id", daprIds.CheckoutApi);
    }
    else
    {
        baseAddress = new Uri(builder.Configuration["cartUrl"]);
    }

    client.BaseAddress = baseAddress;
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
