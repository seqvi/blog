using System.Security.Claims;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.FeatureManagement;

namespace blogapi.WhoAmI;

/// <summary>
/// 1. Проверить фичер флаг
///
/// 1. модуль для подключения
/// 2. ендпоинт
/// 3. сам сервис
/// 
/// </summary>
public static class WhoAmIFeature
{
    public static bool CheckFeatures([FromServices] IFeatureManager featureManager)
    => featureManager.IsEnabledAsync("whoami").GetAwaiter().GetResult();
    
    public static IServiceCollection AddServices(this IServiceCollection services)
    => services;

    public static IEndpointConventionBuilder MapEndpoints(this IEndpointRouteBuilder routeBuilder)
    => routeBuilder.MapGet("/whoami",  (HttpContext context) => context.User.Identity?.Name ?? "anonymous").WithName("WhoAmI").WithOpenApi();

}

