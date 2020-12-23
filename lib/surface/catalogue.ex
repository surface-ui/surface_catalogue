defmodule Surface.Catalogue do
  @type option :: {:head, String.t()}

  @callback config :: [option]
end
