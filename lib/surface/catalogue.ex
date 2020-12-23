defmodule Surface.Catalogue do
  @callback config :: keyword()

  # TODO: Add callback `paths/1` to configure where examples/playgrounds are located.
  # This way we can compile/load them only in dev.
  #
  # @callback paths :: [binary()]
  # ...
  # def paths(:dev), do: ["examples"]
  # def paths(_), do: []
end
