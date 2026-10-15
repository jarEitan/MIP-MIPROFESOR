using System.Globalization;

var builder = WebApplication.CreateBuilder(args);

// Formato argentino en todo el sitio: precios "8.000" y calificaciones "4,9"
CultureInfo.DefaultThreadCurrentCulture = new CultureInfo("es-AR");
CultureInfo.DefaultThreadCurrentUICulture = new CultureInfo("es-AR");

builder.Services.AddControllersWithViews();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();
app.UseSession();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();
