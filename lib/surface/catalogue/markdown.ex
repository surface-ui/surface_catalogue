defmodule Surface.Catalogue.Markdown do
  @moduledoc false

  def to_html(text, opts \\ [])

  def to_html(nil, _opts) do
    ""
  end

  def to_html(text, opts) do
    strip = Keyword.get(opts, :strip, false)
    class = Keyword.get(opts, :class, "content")

    markdown =
      text
      |> HtmlEntities.decode()
      |> String.trim_leading()

    html =
      case Earmark.as_html(markdown, code_class_prefix: "language-") do
        {:ok, html, messages} ->
          Enum.each(messages, &warn/1)
          html

        {:error, html, messages} ->
          Enum.each(messages, fn
            {:warning, _line, msg} ->
              message = """
              #{msg}

              Original code:

              #{text}
              """

              warn(message)

            msg ->
              warn(msg)
          end)

          html
      end

    if strip do
      html = html |> String.trim_leading("<p>") |> String.trim_trailing("</p>")
      {:safe, html}
    else
      {:safe, ~s(<div class="#{class}">#{html}</div>)}
    end
  end

  defp warn(val) do
    if is_binary(val) do
      IO.warn(val)
    else
      val |> inspect() |> IO.warn()
    end
  end
end
