defmodule Surface.Catalogue.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Surface.Catalogue.PubSub}
    ]

    opts = [strategy: :one_for_one, name: Surface.Catalogue.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
