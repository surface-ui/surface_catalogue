defmodule Surface.Components.Form.TextArea.Example do
  use Surface.Example,
    catalogue: Surface.Components.Catalogue,
    subject: Surface.Components.Form.TextArea

  def render(assigns) do
    ~H"""
    <TextArea
      rows="4"
      opts={{ placeholder: "4 lines of textarea" }}
    />
    """
  end
end
