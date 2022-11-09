#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["PizzaConf.Web/PizzaConf.Web.csproj", "PizzaConf.Web/"]
COPY ["PizzaConf.Models/PizzaConf.Models.csproj", "PizzaConf.Models/"]
RUN dotnet restore "PizzaConf.Web/PizzaConf.Web.csproj"
COPY . .
WORKDIR "/src/PizzaConf.Web"
RUN dotnet build "PizzaConf.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PizzaConf.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PizzaConf.Web.dll"]