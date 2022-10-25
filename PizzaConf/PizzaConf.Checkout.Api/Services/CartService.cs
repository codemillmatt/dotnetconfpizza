using Microsoft.EntityFrameworkCore;
using PizzaConf.Checkout.Api.Data;
using PizzaConf.Models;

namespace PizzaConf.Checkout.Api.Services;

public class CartService
{
    private readonly ShoppingCartContext _shoppingCartContext;

    public CartService(ShoppingCartContext shoppingCartContext) 
    {
        _shoppingCartContext = shoppingCartContext;
    }

    public async Task<IEnumerable<OrderedPizza>> GetCartContents()
    {
        throw new NotImplementedException();
    }


}
