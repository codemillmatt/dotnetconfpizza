using Microsoft.EntityFrameworkCore;
using PizzaConf.Models;

namespace PizzaConf.Menu.Api.Data;

public class PizzaContext : DbContext
{
    public PizzaContext(DbContextOptions<PizzaContext> options) : base(options) { }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.LogTo(Console.WriteLine);
    }

    public DbSet<Pizza> Pizzas => Set<Pizza>();
}

public static class Extensions
{
    public static void CreateDbIfNotExists(this IHost host)
    {
        using var scope = host.Services.CreateScope();

        var services = scope.ServiceProvider;
        var context = services.GetRequiredService<PizzaContext>();
        context.Database.EnsureCreated();
        DbInitializer.Initialize(context);
    }
}
