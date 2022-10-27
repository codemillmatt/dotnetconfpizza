using System.ComponentModel.DataAnnotations;

namespace PizzaConf.Models;

public class OrderedPizza
{
    public int Id { get; set; }

    [Required]
    public string? Name { get; set; }
    

    [Required]
    public string? PizzaDescription {  get; set; }

    [Required]
    public DateTime OrderedDate { get; set; }
}
