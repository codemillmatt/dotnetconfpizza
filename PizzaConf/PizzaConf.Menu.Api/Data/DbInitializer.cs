using PizzaConf.Models;

namespace PizzaConf.Menu.Api.Data;

public static class DbInitializer
{
    public static void Initialize(PizzaContext context)
    {
        if (context.Pizzas.Any())
            return;

        var cheese = new Pizza { Name = "Cheese pizza", Description = "The best cheese pizza in the world", ImageUrl = "https://pizzaconf.azureedge.net/pizzaimages/pizza.jpg" };
        var pepp = new Pizza { Name = "Pepporoni pizza", Description = "Seriously good pepporoni", ImageUrl = "https://pizzaconf.azureedge.net/pizzaimages/pizza.jpg" };

        context.Add(cheese);
        context.Add(pepp);

        context.SaveChanges();
    }
}

