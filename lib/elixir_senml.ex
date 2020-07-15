defmodule ElixirSenml do
  alias ElixirSenml.Resolver

  defdelegate resolve(payload), to: Resolver, as: :start_resolve
  defdelegate unresolve(payload), to: Resolver, as: :stop_resolve
  
end
