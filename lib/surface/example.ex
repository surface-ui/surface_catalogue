defmodule Surface.Example do
  @moduledoc """
  A generic live view to create examples for catalogues.
  """

  @default_config [
    head: """
    <link phx-track-static rel="stylesheet" href="/css/app.css"/>
    <script defer type="module" src="/js/app.js"></script>
    """
  ]

  defmacro __using__(opts) do
    {opts, config} = Keyword.split(opts, [:namespace, :container, :layout])
    subject = Keyword.fetch!(config, :subject)

    quote do
      use Surface.LiveView, unquote(opts)

      alias unquote(subject)
      require Surface.Catalogue.Data, as: Data

      @config unquote(config)
      @before_compile unquote(__MODULE__)

      import Surface, except: [sigil_H: 2]

      defmacrop sigil_H({:<<>>, meta, [string]} = ast, opts) do
        Module.put_attribute(__CALLER__.module, :code, string)

        quote do
          Surface.sigil_H(unquote(ast), unquote(opts))
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    user_config = Module.get_attribute(env.module, :config)

    catalogue_config =
      user_config
      |> Keyword.get(:catalogue)
      |> Surface.Catalogue.Util.get_catalogue_config()

    config =
      @default_config
      |> Keyword.merge(catalogue_config)
      |> Keyword.merge(user_config)

    subject = Keyword.fetch!(user_config, :subject)
    code = Module.get_attribute(env.module, :code)

    quote do
      @moduledoc catalogue: [
                   subject: unquote(subject),
                   config: unquote(config),
                   code: unquote(code)
                 ]
    end
  end
end
