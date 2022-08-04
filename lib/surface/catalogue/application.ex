defmodule Surface.Catalogue.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        {Phoenix.PubSub, name: Surface.Catalogue.PubSub}
      ] ++ endpoint(Mix.env(), Mix.Project.get())

    opts = [strategy: :one_for_one, name: Surface.Catalogue.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp endpoint(:test, Surface.Catalogue.MixProject), do: [Surface.Catalogue.Server.Endpoint]
  defp endpoint(_, _), do: []
end
