defmodule ElixirSenmlTest do
  use ExUnit.Case

  test "api is working as it should" do
    json = ~s([
      {
          "bn":"urn:dev:ow:10e2073a01080063",
          "bt": 1.276020076e+09,
          "u":"Cel",         
          "v":23.5
      },
      {
          "u":"Bel",
          "t":1.276020091e+09,
          "v":23.6
     }
     ]
    )
    
    ElixirSenml.resolve(json)
  end
end
