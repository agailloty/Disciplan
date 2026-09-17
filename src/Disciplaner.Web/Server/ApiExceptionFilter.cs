using Disciplaner.Application.Exceptions;
using Disciplaner.Domain.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Web.Server;

public sealed class ApiExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        var status = context.Exception switch
        {
            UnauthorizedAccessException => StatusCodes.Status403Forbidden,
            NotFoundException => StatusCodes.Status404NotFound,
            DbUpdateConcurrencyException => StatusCodes.Status409Conflict,
            ArgumentException or DomainException => StatusCodes.Status400BadRequest,
            _ => 0
        };
        if (status == 0) return;
        context.Result = new ObjectResult(new ProblemDetails
        {
            Status = status,
            Title = status switch { 403 => "Access denied.", 404 => "Resource not found.", 409 => "The resource has changed. Reload and retry.", _ => context.Exception.Message }
        }) { StatusCode = status };
        context.ExceptionHandled = true;
    }
}
