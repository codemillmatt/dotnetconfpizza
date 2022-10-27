using Microsoft.EntityFrameworkCore;
using PizzaConf.Checkout.Api.Data;
using PizzaConf.Models;

namespace PizzaConf.Checkout.Api.Services;

public class CartService
{
    private readonly ShoppingCartContext _context;

    public CartService(ShoppingCartContext shoppingCartContext) 
    {
        _context = shoppingCartContext;
    }

    public async Task<IEnumerable<OrderedPizza>> GetCartContents()
    {
        var orderedPizzas = await _context.Pizzas.AsNoTracking().ToListAsync();

        return orderedPizzas;
    }

    public async Task<OrderedPizza> OrderPizza(OrderedPizza pizza)
    {
        await _context.Pizzas.AddAsync(pizza);

        await _context.SaveChangesAsync();

        return pizza;
    }

    public async Task PlaceOrder()
    {
        // just delete everything
        _context.Pizzas.RemoveRange(await _context.Pizzas.ToArrayAsync());

        await _context.SaveChangesAsync();
    }

}
