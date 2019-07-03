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
            |> to_compact_map() # returns a struct without the nil value keys
            |> process_fields(resolver)    
            |> increment_record_counter()    
        end)     
    end
    def resolve([], _), do: { :error, "empty payload"}    


    def process_fields(record, resolver) do        
        upset_resolver = process_base_fields(record, resolver)
        resolve_record = process_regular_keys(upset_resolver, record)

        Map.put(upset_resolver, :resolved, MapSet.put(upset_resolver.resolved, resolve_record))
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

    # todo
    def process_regular_keys(resolver, record) do
        %ResolveRecord{            
            n: resolve_name(resolver, record),
            u: resolve_unit(resolver, record),
            t: resolve_time(resolver, record),   
            v: resolve_value(resolver, record),   
            s: resolve_sum(resolver, record),      
        }   
    end

    def base_bn?(resolver, %{ bn: bn }), do: %{ resolver | bn: bn }
    def base_bn?(resolver, _), do: resolver

    def base_bu?(resolver, %{ bu: bu }), do: %{ resolver | bu: bu }
    def base_bu?(resolver, _), do: resolver

    def base_bt?(resolver, %{ bt: bt }), do: %{ resolver | bt: bt }
    def base_bt?(resolver, _), do: resolver

    def base_bv?(resolver, %{ bv: bv }), do: %{ resolver | bv: bv }
    def base_bv?(resolver, _), do: resolver

    def base_bs?(resolver, %{ bs: bs }), do: %{ resolver | bs: bs }
    def base_bs?(resolver, _), do: resolver

    def base_bver?(resolver, %{ bver: bver}), do: %{ resolver | bver: bver }
    def base_bver?(resolver, _), do: resolver

    def resolve_name(%{ bn: bn}, %{ n: n }), do: "#{bn}#{n}"
    def resolve_name(%{ bn: bn}, _), do: bn
    def resolve_name(_, %{ n: n }), do: n        

    def resolve_unit(%{ bu: _bu}, %{ u: u }), do: u
    def resolve_unit(%{ bu: bu}, _), do: bu
    def resolve_unit(_, %{ u: u }), do: u      

    def resolve_time(%{ bt: _bt}, %{ t: t }), do: t
    def resolve_time(%{ bt: bt}, _), do: bt
    def resolve_time(_, %{ t: t }), do: t    

    def resolve_value(%{ bv: _bv}, %{ v: v }), do: v
    def resolve_value(%{ bv: bv}, _), do: bv
    def resolve_value(_, %{ v: v }), do: v

    def resolve_sum(%{ bs: _bs}, %{ s: s }), do: s
    def resolve_sum(%{ bs: bs}, _), do: bs
    def resolve_sum(_, %{ s: s }), do: s

    def resolve_version(_, %{ bver: bver }) when bver > @supported_version do
        { :error, "unsupported version" }
    end
    def resolve_version(_, %{ bver: bver }) when bver <= @supported_version do
        bver
    end
    def resolve_version(%{ bver: bver}, _), do: bver
    def resolve_version(_, _), do: @supported_version

    def increment_record_counter(resolver = %{ number_records: number_records }), do: %{ resolver | number_records: number_records + 1 } 

    def to_compact_map(map) do
        map
        |> Enum.reject(fn({_, v}) -> v == nil end)
        |> Enum.into(%{})
    end
end