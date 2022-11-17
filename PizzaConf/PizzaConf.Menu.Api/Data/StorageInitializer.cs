using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace PizzaConf.Menu.Api.Data;

public static class StorageInitializer
{
    public static async Task UploadImages(this IHost host, string? storageUrl)
    {
        if (string.IsNullOrEmpty(storageUrl))
            return;

        BlobContainerClient containerClient = new BlobContainerClient(new Uri(storageUrl), new DefaultAzureCredential());

        foreach (var imageFileName in Directory.GetFiles("media"))
        {
            try
            {
                var imageClient = containerClient.GetBlobClient(imageFileName);

                var blobExists = (await imageClient.ExistsAsync()).Value;

                if (!blobExists)
                    await imageClient.UploadAsync(imageFileName, overwrite: false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
            }
        }

        
    }
}
