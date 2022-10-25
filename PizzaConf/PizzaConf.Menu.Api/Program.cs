using Microsoft.AspNetCore.Mvc;
using PizzaConf.Menu.Api.Data;
using PizzaConf.Menu.Api.Services;
using PizzaConf.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSqlite<PizzaContext>("Data Source=pizza.db");

builder.Services.AddTransient<PizzaService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();


app.MapGet("/pizzas", async ([FromServices]PizzaService pizzaService) =>
{
    var pizzas = await pizzaService.GetPizzas();

    return Results.Ok(pizzas);
})
.WithName("GetAllPizzas")
.WithOpenApi()
.Produces<IEnumerable<Pizza>>(StatusCodes.Status200OK);

app.MapGet("/pizzas/{id}", async (int id, [FromServices]PizzaService pizzaService) =>
{
    var pizza = await pizzaService.GetPizzaById(id);

    if (pizza == null)
        return Results.NotFound();
    else
        return Results.Ok(pizza);
})
.WithName("GetIndividualPizza")
.WithOpenApi()
.Produces(StatusCodes.Status404NotFound)
.Produces<Pizza>(StatusCodes.Status200OK);

app.CreateDbIfNotExists();

app.Run();
