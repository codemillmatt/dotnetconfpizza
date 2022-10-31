using PizzaConf.Checkout.Api.Data;
using PizzaConf.Checkout.Api.Services;
using Microsoft.AspNetCore.Mvc;
using PizzaConf.Models;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Configuration.AddAzureAppConfiguration((options) =>
{
    options.Connect(new Uri(builder.Configuration["appConfigUrl"]), new DefaultAzureCredential())
        .Select("CheckoutDb")
        .ConfigureKeyVault((kvOptions) => kvOptions.SetCredential(new DefaultAzureCredential()));
});

//builder.Services.AddSqlite<ShoppingCartContext>("Data Source=checkout.db");
builder.Services.AddSqlServer<ShoppingCartContext>
    (builder.Configuration["CheckoutDb"],
    (options) => options.EnableRetryOnFailure());


builder.Services.AddTransient<CartService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/cart", async ([FromServices]CartService cart) =>
{
    var contents = await cart.GetCartContents();

    return Results.Ok(contents);
})
.WithName("GetCartContents")
.Produces<IEnumerable<OrderedPizza>>(StatusCodes.Status200OK)
.WithOpenApi();

app.MapDelete("/cart", async ([FromServices] CartService cart) =>
{
    await cart.PlaceOrder();

    return Results.NoContent();
})
.WithName("PlaceOrder")
.Produces(StatusCodes.Status204NoContent)
.WithOpenApi();

app.MapPost("/order", async ([FromBody] OrderedPizza pizza, [FromServices] CartService cart) =>
{
    var orderedPizza = await cart.OrderPizza(pizza);

    return Results.CreatedAtRoute(routeName: "OrderPizza", value: orderedPizza);
})
.WithName("OrderPizza")
.Produces<OrderedPizza>(StatusCodes.Status201Created)
.WithOpenApi();

app.CreateDbIfNotExists();

app.Run();


