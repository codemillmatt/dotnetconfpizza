using Microsoft.EntityFrameworkCore;
using PizzaConf.Menu.Api.Data;
using PizzaConf.Models;

namespace PizzaConf.Menu.Api.Services;

public class PizzaService
{
    private readonly PizzaContext _context;

    public PizzaService(PizzaContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Pizza>> GetPizzas()
    {
        return await _context.Pizzas.AsNoTracking().ToListAsync();
    }

    public async Task<Pizza?> GetPizzaById(int id)
    {
        var pizza = await _context.Pizzas.FindAsync(id);

        return pizza;
    }
}
