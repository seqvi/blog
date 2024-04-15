using blogctl;
using Cocona;

var app = CoconaApp.Create();

app.AddCommands<ServiceCommands>();

app.Run();