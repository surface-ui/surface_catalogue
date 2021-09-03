defmodule Surface.Catalogue.Screenshotter do
  alias Surface.Catalogue.Util

  def list_examples do
    {_, examples_and_playgrounds} = Util.get_components_info()

    for {_, component} <- examples_and_playgrounds, example <- component.examples, do: example
  end

  def screenshot_examples(opts) do
    list_examples()
    |> Enum.map(fn example ->
      example |> example_url(opts) |> screenshot(opts)
    end)
  end

  def screenshot(url, _opts \\ []) do
    {:ok, session} = Wallaby.start_session()

    session
    |> Wallaby.Browser.visit(to_string(url))
    |> Wallaby.Browser.take_screenshot(log: true)

    url
  end

  def example_url(module, opts) do
    base_url = Keyword.fetch!(opts, :base_url) |> URI.parse()
    path = Path.join(base_url.path, to_string(module))
    %URI{base_url | path: path}
  end
end
