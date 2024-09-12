# This file is autogenerated by blend package.
#
# Run `mix blend.premix` to update it's contents after
# each blend package version update.

maybe_put_env = fn varname, value ->
  System.put_env(varname, System.get_env(varname, value))
end

existing_blend = fn name ->
  Code.eval_file("blend.exs")
  |> elem(0)
  |> Map.fetch!(String.to_atom(name))
end

blend = System.get_env("BLEND")

if blend && String.length(blend) > 0 && existing_blend.(blend) do
  maybe_put_env.("MIX_LOCKFILE", "blend/#{blend}.mix.lock")
  maybe_put_env.("MIX_DEPS_PATH", "blend/deps/#{blend}")
  maybe_put_env.("MIX_BUILD_ROOT", "blend/_build/#{blend}")
end

defmodule Blend.Premix do
  def patch_project(project) do
    Keyword.merge(project, maybe_lockfile_option())
  end

  def patch_deps(mix_deps) do
    patch_deps(System.get_env("BLEND"), mix_deps)
  end

  defp patch_deps(nil, mix_deps), do: mix_deps
  defp patch_deps("", mix_deps), do: mix_deps

  defp patch_deps(blend, mix_deps) do
    blend_deps(blend)
    |> Enum.reduce(mix_deps, fn blend_dep, acc ->
      verify_requirements!(blend, blend_dep, mix_deps)
      List.keystore(acc, elem(blend_dep, 0), 0, blend_dep)
    end)
  end

  defp blend_deps(name) do
    {blends, []} = Code.eval_file("blend.exs")
    Map.fetch!(blends, String.to_atom(name))
  end

  defp maybe_lockfile_option() do
    case System.get_env("MIX_LOCKFILE") do
      nil -> []
      "" -> []
      lockfile -> [lockfile: lockfile]
    end
  end

  defp verify_requirements!(blend, blend_dep, mix_deps) do
    blend_app = elem(blend_dep, 0)
    blend_requirement = elem(blend_dep, 1)
    mix_dep = List.keyfind!(mix_deps, blend_app, 0)
    mix_requirement = elem(mix_dep, 1)

    if is_binary(blend_requirement) and
         not Hex.Solver.Constraint.allows_all?(
           Hex.Solver.parse_constraint!(mix_requirement),
           Hex.Solver.parse_constraint!(blend_requirement)
         ) do
      Mix.shell().error(
        "Blend `#{blend}` requirement `#{blend_requirement}` outside project requirement range `#{mix_requirement} for `#{blend_app}` check mix.exs or blend.exs."
      )

      Mix.shell().error("""
      Blend requirement for `#{blend}` incompatible with project requirement:
        in mix.exs   #{inspect(mix_dep)}
        in blend.exs #{inspect(blend_dep)}.
      """)

      exit({:shutdown, 1})
    end
  end
end
