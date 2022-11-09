using PizzaConf.Models;

namespace PizzaConf.Web.Data;

public class CartWebService
{
    private readonly HttpClient _httpClient;

    public CartWebService (HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IEnumerable<OrderedPizza>?> GetCartContents()
    {
        string url = "/cart";

        var contents = await _httpClient.GetFromJsonAsync<IEnumerable<OrderedPizza>>(url);

        return contents;
    }

    public async Task AddPizzaToOrder(string name, string description)
    {
        OrderedPizza pizza = new() { Name = name, PizzaDescription = description, OrderedDate = DateTime.Now };

        string url = "/order";

        await _httpClient.PostAsJsonAsync(url, pizza);
    }

    public async Task<int> PlaceOrder()
    {
        string url = "/cart";

        await _httpClient.DeleteAsync(url);

        return Random.Shared.Next(0, 100);
    }
}
