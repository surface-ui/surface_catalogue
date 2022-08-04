defmodule Surface.Catalogue.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Surface.Catalogue.ConnCase
      use Surface.LiveViewTest

      alias Surface.Catalogue.Router.Helpers, as: Routes

      @endpoint Surface.Catalogue.Server.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
