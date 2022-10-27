using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using PizzaConf.Web.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<PizzaWebService>();
builder.Services.AddSingleton<CartWebService>();

builder.Services.AddHttpClient<PizzaWebService>(client =>
{
    var baseAddress = new Uri(builder.Configuration["menuUrl"]);
    client.BaseAddress = baseAddress;
});

builder.Services.AddHttpClient<CartWebService>(client =>
{
    var baseAddress = new Uri(builder.Configuration["cartUrl"]);
    client.BaseAddress = baseAddress;
});

builder.Services.AddSingleton<HttpClient>();

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
