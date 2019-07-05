defmodule ElixirSenml.Resolver do
  alias ElixirSenml.Record
  alias ElixirSenml.ResolveRecord

  @supported_version 12

  # keep the state during the resolver loop process
  defstruct(
    bn: nil,
    bu: nil,
    bt: nil,
    bv: nil,
    bs: nil,
    bver: nil,
    number_records: 0,
    resolved: MapSet.new()
  )

  # resolve Senml payload
  # needs to add to guards to assure that the payload is not empty and it's a JSON format
  # payload = [{},{},...]
  def start_resolve(payload) do
    Poison.decode!(payload, as: [%Record{}])
    |> resolve()
  end

  # In case the Poison.decode returns an error
  def resolve(records) do
    Enum.reduce(records, %ElixirSenml.Resolver{}, fn record, resolver ->
      Map.from_struct(record)
      # returns a struct without the nil value keys
      |> to_compact_map()
      |> process_fields(resolver)
      |> increment_record_counter()
    end)
  end

  def resolve([], _), do: {:error, "empty payload"}

  def process_fields(record, resolver) do
    upset_resolver = process_base_fields(record, resolver)
    resolved_record = process_regular_fields(upset_resolver, record)

    Map.put(upset_resolver, :resolved, MapSet.put(upset_resolver.resolved, resolved_record))
  end

  def process_base_fields(rec_struct, resolver) do
    resolver
    |> base_bn?(rec_struct)
    |> base_bu?(rec_struct)
    |> base_bt?(rec_struct)
    |> base_bv?(rec_struct)
    |> base_bs?(rec_struct)
    |> base_bver?(rec_struct)
  end

  def process_regular_fields(resolver, record) do
    with {:ok, n} <- resolve_name(resolver, record),
         {:ok, u} <- resolve_unit(resolver, record),
         {:ok, t} <- resolve_time(resolver, record),
         {:ok, v} <- resolve_value(resolver, record),
         {:ok, s} <- resolve_sum(resolver, record),
         {:ok, bver} <- resolve_base_version(resolver, record) 
    do
      %ResolveRecord{
        n: n,
        u: u,
        t: t,
        v: v,
        s: s,
        bver: bver
      }      
    else
      err -> err
    end
  end

  def base_bn?(resolver, %{bn: bn}) when bn in [nil, ""], do: resolver
  def base_bn?(resolver, %{bn: bn}), do: %{resolver | bn: bn}
  def base_bn?(resolver, _), do: resolver

  def base_bu?(resolver, %{bu: bu}) when bu in [nil, ""], do: resolver
  def base_bu?(resolver, %{bu: bu}), do: %{resolver | bu: bu}
  def base_bu?(resolver, _), do: resolver

  def base_bt?(resolver, %{bt: bt}) when bt in [nil, ""], do: resolver
  def base_bt?(resolver, %{bt: bt}), do: %{resolver | bt: bt}
  def base_bt?(resolver, _), do: resolver

  def base_bv?(resolver, %{bv: bv}) when bv in [nil, ""], do: resolver
  def base_bv?(resolver, %{bv: bv}), do: %{resolver | bv: bv}
  def base_bv?(resolver, _), do: resolver

  def base_bs?(resolver, %{bs: bs}) when bs in [nil, ""], do: resolver
  def base_bs?(resolver, %{bs: bs}), do: %{resolver | bs: bs}
  def base_bs?(resolver, _), do: resolver

  def base_bver?(resolver, %{bver: bver}) when bver in [nil, ""], do: resolver
  def base_bver?(resolver, %{bver: bver}), do: %{resolver | bver: bver}
  def base_bver?(resolver, _), do: resolver

  def resolve_name(%{bn: bn}, %{n: n}), do: {:ok, "#{bn}#{n}"}
  def resolve_name(%{bn: bn}, _), do: {:ok, bn}
  def resolve_name(_, %{n: n}), do: {:ok, n}
  def resolve_name(_, _), do: {:error, "neither base-name or name field are present"}
  
  def resolve_unit(%{bu: _bu}, %{u: u}), do: {:ok, u}
  def resolve_unit(%{bu: bu}, _), do: {:ok, bu}
  def resolve_unit(_, %{u: u}), do: {:ok, u}
  def resolve_unit(_, _), do: {:ok, nil}

  def resolve_time(%{bt: bt}, %{t: t}), do: {:ok, t+bt}
  def resolve_time(%{bt: bt}, _), do: {:ok, bt}
  def resolve_time(_, %{t: t}), do: {:ok, t}
  def resolve_time(_, _), do: {:ok, 0}

  def resolve_value(%{bv: _bv}, %{v: v}), do: {:ok, v}
  def resolve_value(%{bv: bv}, _), do: {:ok, bv}
  def resolve_value(_, %{v: v}), do: {:ok, v}
  def resolve_value(_, _), do: {:ok, nil}

  def resolve_sum(%{bs: _bs}, %{s: s}), do: {:ok, s}
  def resolve_sum(%{bs: bs}, _), do: {:ok, bs}
  def resolve_sum(_, %{s: s}), do: {:ok, s}
  def resolve_sum(_, _), do: {:ok, nil}

  def resolve_base_version(_, %{bver: bver}) when bver > @supported_version do
    {:error, "unsupported version"}
  end

  def resolve_base_version(_, %{bver: bver}) when bver <= @supported_version do
    {:ok, bver}
  end

  def resolve_base_version(%{bver: bver}, _), do: {:ok, bver}
  def resolve_base_version(_, _), do: {:ok, @supported_version}

  def increment_record_counter(resolver = %{number_records: number_records}),
    do: %{resolver | number_records: number_records + 1}

  def to_compact_map(map) do
    map
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Enum.into(%{})
  end
end
