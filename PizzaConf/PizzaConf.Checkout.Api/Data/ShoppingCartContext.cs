using Microsoft.EntityFrameworkCore;
using PizzaConf.Models;

namespace PizzaConf.Checkout.Api.Data;

public class ShoppingCartContext : DbContext
{
    public ShoppingCartContext(DbContextOptions<ShoppingCartContext> options): base(options) { }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder) => optionsBuilder.LogTo(Console.WriteLine);

    public DbSet<OrderedPizza> Pizzas => Set<OrderedPizza>();
}

public static class Extensions
{
    public static void CreateDbIfNotExists(this IHost host)
    {
        using var scope = host.Services.CreateScope();

        var services = scope.ServiceProvider;
        var context = services.GetRequiredService<ShoppingCartContext>();
        context.Database.EnsureCreated();
        DbInitializer.Initialize(context);
    }
}