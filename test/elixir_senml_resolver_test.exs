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
            v: 10.10,

        }
        
        expected_value = MapSet.put(MapSet.new, %ElixirSenml.ResolveRecord{
            n: raw_record.bn,
            t: raw_record.bt,
            u: raw_record.u,
            v: raw_record.v,  
            s: raw_record.bs,    
        })

        actual_value = ElixirSenml.Resolver.resolve([raw_record])

        assert MapSet.size(actual_value.resolved) == 1
        assert actual_value.number_records == 1
        assert expected_value == actual_value.resolved
        
    end

    test "create two resolver records with success" do
        raw_record = [%ElixirSenml.Record{
            bn: "urn:dev:ow:10e2073a01080063/",
            bt: 1111.111,
            bs: 12,
            u: "Cel",
            v: 10.10,
        }, %ElixirSenml.Record{
            n: "name",
            bt: 1111.111,
            bs: 12,
            u: "Cel",
            v: 10.10,
        }]
        
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
            bver: 10,
        }

        expected_value = %Resolver{
            bn: record.bn,
            bt: record.bt,
            bu: record.bu,
            bv: record.bv,
            bs: record.bs,
            bver: record.bver,
            number_records: 0,
            resolved: MapSet.new(),
        }

        actual_value = Resolver.process_base_fields(record, %Resolver{})
        assert expected_value == actual_value
    end

    test "resolver set with regular field 'n' expanded with base field 'bn' when both are set" do
        record = %Record{
            n: "name",
        }

        resolver = %Resolver{
            bn: "base-name/",
        }
        
        expected_value = %ResolveRecord{
            n: "base-name/name"
        }

        actual_value = Resolver.process_regular_keys(resolver, record)
        assert expected_value == actual_value
    end

    test "resolver set with regular field 'n' when 'bn' is not present" do
        record = %Record{
            n: "name",
        }

        resolver = %Resolver{        
            bn: nil,
        }
        
        expected_value = %ResolveRecord{
            n: "name"
        }

        actual_value = Resolver.process_regular_keys(resolver, record)
        assert expected_value == actual_value
    end

    test "resolve name when 'bn' and 'n' fields are set" do
        assert "first-name/name" == Resolver.resolve_name(%{ bn: "first-name/"}, %{ n: "name" })
    end
    
    test "resolve time with 't' when both are set" do
        assert 111.111 == Resolver.resolve_time(%{ bt: 222.222}, %{ t: 111.111 })
    end

    test "resolve time with 'bt' when 't' is not set" do
        assert 222.222 == Resolver.resolve_time(%{ bt: 222.222}, %{ })
    end

    test "resolve time with 't' when 'bt' is not set" do
        assert 111.111 == Resolver.resolve_time(%{ }, %{ t: 111.111 })
    end

    test "the record bver value is supported" do
        assert 12 == Resolver.resolve_version(%{ bver: 12 }, %{ bver: 12 })
    end

    test "the record bver value is not supported" do
        assert { :error, "unsupported version" } == Resolver.resolve_version(%{ bver: 12 }, %{ bver: 13 })
    end
end