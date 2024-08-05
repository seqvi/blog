using System.Reflection;
using blogapi.WhoAmI;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.HttpLogging;
using Microsoft.AspNetCore.Mvc;
using OpenTelemetry.Resources;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var serviceName = Assembly.GetEntryAssembly()?.GetName().Name!;

builder.Logging
    .AddJsonConsole()
    .AddOpenTelemetry(x =>
{
    x.IncludeScopes = true;
    x.IncludeFormattedMessage = true;
    x.ParseStateValues = true;
    
    x.SetResourceBuilder(
            ResourceBuilder.CreateDefault()
                .AddTelemetrySdk()
                .AddEnvironmentVariableDetector()
                .AddContainerDetector()
                .AddService(serviceName))
        .AddOtlpExporter()
        .AddConsoleExporter();
});

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r =>
        r.AddTelemetrySdk()
            .AddEnvironmentVariableDetector()
            .AddContainerDetector()
            .AddService(serviceName))
    .WithLogging(x =>
    {
        x.AddOtlpExporter()
            .AddConsoleExporter();
    })
    .WithMetrics(x =>
    {
        x.AddMeter("Microsoft.AspNetCore.Hosting", "Microsoft.AspNetCore.Hosting")
            .AddHttpClientInstrumentation()
            .AddAspNetCoreInstrumentation()
            .AddOtlpExporter();
    })
    .WithTracing(x =>
    {
        x.AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddSqlClientInstrumentation()
            .AddEntityFrameworkCoreInstrumentation();
            
        x.AddOtlpExporter();
    });

builder.Services.AddHttpLogging(options =>
{
    options.LoggingFields = HttpLoggingFields.All;
    options.CombineLogs = true;
    options.ResponseHeaders
        .Add("Token");
    options.ResponseHeaders
        .Add("Remote-User");
    options.MediaTypeOptions.AddText("application/json");
    options.MediaTypeOptions.AddText("text/plain");
    
    options.RequestHeaders.Add("Authorization");
    options.RequestHeaders.Add("Remote-User");
    
});

builder.Services.AddServices();

var app = builder.Build();

app.UseHttpLogging();

app.UseSwagger();
app.UseSwaggerUI();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.MapGet("/strict/secret", () => "{ \"Error\": \"not implemented yet\"}");

app.MapGet("/secret", () => "{ \"Error\": \"not implemented yet\"}");

app.MapEndpoints();

app.MapGet("/whoami2", (HttpContext context) => Results.Ok(context.User.Identity?.Name ?? "Anonymous") ).WithName("WhoAmI2").WithOpenApi();


app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
