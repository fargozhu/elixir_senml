defmodule ElixirSenml do
  alias ElixirSenml.ResolverStatus

  defdelegate resolve(payload), to: ResolverStatus, as: :start_resolve
end
