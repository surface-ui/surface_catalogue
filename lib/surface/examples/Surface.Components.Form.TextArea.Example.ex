defmodule Surface.Components.Form.TextArea.Example do
  use Surface.LiveView

  @moduledoc catalogue: [
               title: "Example #1",
               head: """
               <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
               """,
               code: File.read!(__ENV__.file)
             ]

  alias Surface.Components.Form.TextArea

  def render(assigns) do
    ~H"""
    <TextArea
      rows="4"
      opts={{ placeholder: "4 lines of textarea" }}
    />
    """
  end
end
