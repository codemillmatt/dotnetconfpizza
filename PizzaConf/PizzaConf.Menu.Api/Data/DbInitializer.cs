using PizzaConf.Models;

namespace PizzaConf.Menu.Api.Data;

public static class DbInitializer
{
    public static void Initialize(PizzaContext context)
    {
        if (context.Pizzas.Any())
            return;

        var cheese = new Pizza { Name = "Lotsa Mozza", Description = "The best cheese pizza in the world", ImageUrl = "pizza1.jpg" };
        var pepp = new Pizza { Name = "Put some pep in your step", Description = "Seriously good pepporoni", ImageUrl = "pizza2.jpg" };
        var at = new Pizza { Name = "Don't at me", Description = "Pineapple on a pizza", ImageUrl = "pizza3.jpg" };
        var forest = new Pizza { Name = "Forest floor", Description = "Pineapple on a pizza", ImageUrl = "pizza4.jpg" };

        context.Add(cheese);
        context.Add(pepp);
        context.Add(at);
        context.Add(forest);

        context.SaveChanges();
    }
}

