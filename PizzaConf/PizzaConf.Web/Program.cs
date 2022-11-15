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
    string? appConfigUrl = builder.Configuration["appConfigUrl"] ?? "";
    if (string.IsNullOrEmpty(appConfigUrl))
        throw new NullReferenceException($"{nameof(appConfigUrl)} needs to be set to the value of the Azure App Config url");

    // Make sure it doesn't blow up because it doesn't have access to key vault
    options.Connect(new Uri(appConfigUrl), new DefaultAzureCredential())
        .Select("cartUrl").Select("menuUrl").Select("trackingUrl").Select("DaprAppId*").Select("cdnUrl")
        .ConfigureKeyVault(options => new DefaultAzureCredential());
});

var daprIds = builder.Configuration.GetSection("DaprAppId:PizzaConf").Get<DaprAppId>();

builder.Services.AddHttpClient<PizzaWebService>(client =>
{
    string url = builder.Configuration["menuUrl"] ?? "http://localhost:3500";
    Uri baseAddress = new(url);

    if (!string.IsNullOrEmpty(daprIds?.MenuApi))
    {
        client.DefaultRequestHeaders.Add("dapr-app-id", daprIds.MenuApi);
    }

    client.BaseAddress = baseAddress;
});

builder.Services.AddHttpClient<CartWebService>(client =>
{
    string url = builder.Configuration["cartUrl"] ?? "http://localhost:3500";
    Uri baseAddress = new(url);

    if (!string.IsNullOrEmpty(daprIds?.CheckoutApi))
    {        
        client.DefaultRequestHeaders.Add("dapr-app-id", daprIds.CheckoutApi);
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
