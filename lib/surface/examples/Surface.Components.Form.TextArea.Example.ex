defmodule Surface.Components.Form.TextArea.Example do
  use Surface.Example,
    subject: Surface.Components.Form.TextArea,
    # TODO: Remove this after moving css files to assets/
    head: """
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
    """

  def render(assigns) do
    ~H"""
    <TextArea
      rows="4"
      opts={{ placeholder: "4 lines of textarea" }}
    />
    """
  end
end
