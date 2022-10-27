using System.ComponentModel.DataAnnotations;

namespace PizzaConf.Models;

public class Pizza
{
    
    public int Id { get; set; }

    [Required]
    public string? Name { get; set; }

    [Required]
    public string? Description { get; set; }

    [Required]
    public string? ImageUrl { get; set; }
}
