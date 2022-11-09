using PizzaConf.Models;

namespace PizzaConf.Web.Data;

public class PizzaWebService
{
    private readonly HttpClient _httpClient;

    public PizzaWebService(HttpClient client)
    {
        _httpClient = client;
    }

    public async Task<IEnumerable<Pizza>?> GetMenu()
    {
        var allThePizzas = await _httpClient.GetFromJsonAsync<IEnumerable<Pizza>?>("/pizzas");

        return allThePizzas;
    }

    public async Task<Pizza?> GetPizza(int pizzaId)
    {
        var url = $"/pizzas/{pizzaId}";

        var thePizza = await _httpClient.GetFromJsonAsync<Pizza>(url);

        return thePizza;
    }
}
