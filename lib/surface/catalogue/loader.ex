defmodule Surface.Catalogue.Loader do
  @moduledoc false

  use GenServer

  def init(_) do
    {:ok, load_catalogues()}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_examples_and_playgrounds do
    GenServer.call(__MODULE__, :get_examples_and_playgrounds)
  end

  def handle_call(:get_examples_and_playgrounds, _from, examples_and_playgrounds) do
    {:reply, examples_and_playgrounds, examples_and_playgrounds}
  end

  defp load_catalogues do
    IO.puts "Loading external catalogues...\n"
    catalogues = Surface.Catalogue.Util.get_catalogues()
    Enum.reduce(catalogues, %{}, &compile/2)
  end

  def compile(catalogue, items) do
    files = catalogue.path() |> Path.join("**/*.ex") |> Path.wildcard()

    case Kernel.ParallelCompiler.compile_to_path(files, build_path()) do
      {:ok, modules, _warnings} ->
        items = classify_modules(modules, catalogue, items)
        IO.puts ""
        items

      {:error, errors, warnings} ->
        IO.warn("could not compile catalogue #{inspect(catalogue)}")
        Enum.each(errors ++ warnings, &print_warn/1)
        items
    end
  end

  defp print_warn({_file, _line, message}) do
    IO.warn(message)
  end

  defp classify_modules([], catalogue, items) do
    IO.warn("Catalogue \"#{inspect(catalogue)}\" has no examples nor playgrounds defined in \"#{catalogue.path()}\"")
    items
  end

  defp classify_modules(modules, catalogue, items) do
    IO.puts("Catalogue \"#{inspect(catalogue)}\" loaded with the following items:")
    Enum.reduce(modules, items, fn mod, items ->
      case Surface.Catalogue.Util.get_metadata(mod) do
        %{subject: subject, code: _} ->
          IO.puts("  Example \"#{inspect(mod)}\" for component \"#{inspect(subject)}\"")
          IO.inspect(Application.get_application(mod))
          initial = %{examples: [mod], playgrounds: []}
          Map.update(items, subject, initial, fn info ->
            %{info | examples: [mod | info.examples]}
          end)

        %{subject: subject} ->
          IO.puts("  Playground \"#{inspect(mod)}\" for component \"#{inspect(subject)}\"")
          IO.inspect(Application.get_application(mod))
          initial = %{examples: [], playgrounds: [mod]}
          Map.update(items, subject, initial, fn info ->
            %{info | playgrounds: [mod | info.playgrounds]}
          end)
      end
    end)
  end

  defp build_path() do
    :surface_catalogue
    |> Application.app_dir()
    |> Path.join("ebin")
    |> Path.relative_to_cwd()
  end
end
