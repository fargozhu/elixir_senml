defmodule ElixirSenml.ResolveRecord do
  @type t :: %__MODULE__{
          n: String.t(),
          t: integer,
          v: float,
          vs: String.t(),
          vd: String.t(),
          vb: boolean,
          s: integer,
          u: String.t(),
          ut: integer,
          ct: String.t(),
          bver: integer
        }

  defstruct n: nil,
            t: nil,
            v: nil,
            vs: nil,
            vb: nil,
            vd: nil,
            s: nil,
            u: nil,
            ut: nil,
            ct: nil,
            bver: nil
end
