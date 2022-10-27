using PizzaConf.Models;

namespace PizzaConf.Web.Data;

public class CartWebService
{
    private readonly HttpClient _httpClient;

    public CartWebService (HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IEnumerable<OrderedPizza>> GetCartContents()
    {
        throw new NotImplementedException();
    }

    public async Task AddPizzaToOrder(string description)
    {
        throw new NotImplementedException();
    }

    public async Task PlaceOrder()
    {
        throw new NotImplementedException();
    }
}
