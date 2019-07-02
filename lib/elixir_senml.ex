defmodule ElixirSenml do
  alias ElixirSenml.Resolver

  defdelegate resolve(payload), to: Resolver, as: :start_resolve
end
