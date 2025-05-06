defmodule Surface.Catalogue.CatalogueTest do
  use Surface.Catalogue.ConnCase, async: true

  setup_all do
    Application.put_env(:surface_catalogue, Surface.Catalogue.Server.Endpoint,
      secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
      live_view: [signing_salt: "hMegieSe"]
    )

    start_supervised!(Surface.Catalogue.Server.Endpoint)

    :ok
  end

  catalogue_test :all
end
