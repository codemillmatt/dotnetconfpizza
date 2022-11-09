using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PizzaConf.Models
{
    public class TrackingMessage
    {
        public string? StatusUrl { get; set; }
        public string? Status { get; set; }

        public int OrderId { get; set; }
    }
}
