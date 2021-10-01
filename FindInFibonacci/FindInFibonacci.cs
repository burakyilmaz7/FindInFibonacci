using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace FindInFibonacci
{
    public static class FindInFibonacci
    {
        [FunctionName("FindInFibonacci")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = "v1/FindInFibonacci/{number}")] HttpRequest req,
            long number,
            ILogger log)
        {

            if (number <= 0 || number> Int64.MaxValue)
                return new BadRequestObjectResult("Number is out of range!");

            // Initialize the first & second
            // terms of the Fibonacci series
            long first = 0, second = 1;

            // Store the third term
            long third = first + second;

            // Iterate until the third term
            // is less than or equal to num
            while (third <= number)
            {

                // Update the first
                first = second;

                // Update the second
                second = third;

                // Update the third
                third = first + second;
            }

            return new OkObjectResult(new long[] { first, second, third });
        }
    }
}
