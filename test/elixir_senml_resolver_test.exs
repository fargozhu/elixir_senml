defmodule ElixirSenmlResolverTest do
  use ExUnit.Case
  alias ElixirSenml.Resolver
  alias ElixirSenml.Record
  alias ElixirSenml.ResolveRecord

  test "create a resolver record with success" do
    raw_record = %ElixirSenml.Record{
      bn: "urn:dev:ow:10e2073a01080063",
      bt: 1111.111,
      bs: 12,
      u: "Cel",
      v: 10.10
    }

    expected_value =
      MapSet.put(MapSet.new(), %ElixirSenml.ResolveRecord{
        n: raw_record.bn,
        t: raw_record.bt,
        u: raw_record.u,
        v: raw_record.v,
        s: raw_record.bs
      })

    actual_value = ElixirSenml.Resolver.resolve([raw_record])

    assert MapSet.size(actual_value.resolved) == 1
    assert actual_value.number_records == 1
    assert expected_value == actual_value.resolved
  end

  test "create two resolver records with success" do
    raw_record = [
      %ElixirSenml.Record{
        bn: "urn:dev:ow:10e2073a01080063/",
        bt: 1111.111,
        bs: 12,
        u: "Cel",
        v: 10.10
      },
      %ElixirSenml.Record{
        n: "name",
        bt: 1111.111,
        bs: 12,
        u: "Cel",
        v: 10.10
      }
    ]

    expected_value = 2
    actual_value = ElixirSenml.Resolver.resolve(raw_record)

    assert MapSet.size(actual_value.resolved) == expected_value
    assert actual_value.number_records == expected_value
  end

  test "all base fields loaded into the stack" do
    record = %Record{
      bn: "base-name",
      bt: 1111.111,
      bu: "base-unit",
      bv: 10.10,
      bs: 20.20,
      bver: 10
    }

    expected_value = %Resolver{
      bn: record.bn,
      bt: record.bt,
      bu: record.bu,
      bv: record.bv,
      bs: record.bs,
      bver: record.bver,
      number_records: 0,
      resolved: MapSet.new()
    }

    actual_value = Resolver.process_base_fields(record, %Resolver{})
    assert expected_value == actual_value
  end

  test "resolver set with regular field 'n' expanded with base field 'bn' when both are set" do
    resolver = %Resolver{
      bn: "base-name/",
      bver: 12
    }

    expected_value = %ResolveRecord{
      n: "base-name/name",
      bver: resolver.bver
    }

    actual_value = Resolver.process_regular_fields(resolver, %{n: "name"})
    assert expected_value == actual_value
  end

  test "resolver set with regular field 'n' when 'bn' is not present" do
    resolver = %Resolver{
      bver: 12
    }

    expected_value = %ResolveRecord{
      n: "name",
      bver: resolver.bver
    }

    actual_value = Resolver.process_regular_fields(resolver, %{n: "name"})
    assert expected_value == actual_value
  end

  test "resolve name with success when both 'bn' and 'n' values are set" do
    assert {:ok, "base-name/name"} == Resolver.resolve_name(%{bn: "base-name/"}, %{n: "name"})
  end

  test "resolve name with success when only 'bn' value is set" do
    assert {:ok, "base-name/"} == Resolver.resolve_name(%{bn: "base-name/"}, %{})
  end

  test "resolve name with success when only 'n' value is set" do
    assert {:ok, "name"} == Resolver.resolve_name(%{}, %{n: "name"})
  end

  test "resolve name fail when neither both 'bn' and 'n' values are set" do
    assert {:error, "neither base-name or name field are present"} == Resolver.resolve_name(%{}, %{})
  end

  test "resolve unit with success when only 'bu' is set" do
    assert {:ok, "Cel"} = Resolver.resolve_unit(%{bu: "Cel"}, %{})
  end

  test "resolve unit with success when only 'u' is set" do
    assert {:ok, "Col"} = Resolver.resolve_unit(%{}, %{u: "Col"})
  end

  test "resolve unit with success by returning nil when neither 'bu' and 'u' are set" do
    assert {:ok, nil} = Resolver.resolve_unit(%{}, %{})
  end

  test "resolve unit with success when both 'bu' and 'u' are set by using 'u' value" do
    assert {:ok, "Col"} = Resolver.resolve_unit(%{bu: "Cel"}, %{u: "Col"})
  end

  test "resolve time with 't' when both are set" do
    assert {:ok, 333.333} == Resolver.resolve_time(%{bt: 222.222}, %{t: 111.111})
  end

  test "resolve time with 'bt' when 't' is not set" do
    assert {:ok, 222.222} == Resolver.resolve_time(%{bt: 222.222}, %{})
  end

  test "resolve time with 't' when 'bt' is not set" do
    assert {:ok, 111.111} == Resolver.resolve_time(%{}, %{t: 111.111})
  end

  test "resolve time with '0' when both 'bt' and 't' are not set" do
    assert {:ok, 0} == Resolver.resolve_time(%{}, %{})
  end

  test "resolve value with success when only 'bv' is set" do
    assert {:ok, 10.00} = Resolver.resolve_value(%{bv: 10.00}, %{})
  end

  test "resolve value with success when only 'v' is set" do
    assert {:ok, 20.00} = Resolver.resolve_value(%{}, %{v: 20.00})
  end

  test "resolve unit with success by returning nil when neither 'bv' and 'v' are set" do
    assert {:ok, nil} = Resolver.resolve_value(%{}, %{})
  end

  test "resolve unit with success when both 'bv' and 'v' are set by using 'v' value" do
    assert {:ok, 20.00} = Resolver.resolve_value(%{bv: 10.00}, %{v: 20.00})
  end

  test "resolve version with success when 'bver' value is supported" do
    assert {:ok, 12} = Resolver.resolve_base_version(%{}, %{bver: 12})
  end

  test "resolve version fails when 'bver' value is not supported" do
    assert {:error, "unsupported version"} = Resolver.resolve_base_version(%{}, %{bver: 13})
  end
end
