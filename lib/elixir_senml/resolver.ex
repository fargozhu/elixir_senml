defmodule ElixirSenml.Resolver do
    alias ElixirSenml.Record
    alias ElixirSenml.ResolveRecord

    # keep the state during the resolver loop process
    defstruct(
        bn: nil,
        bu: nil,
        bt: nil,
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
        end)
    end
    def resolve([], _), do: { :error, "empty payload"}    


    def process_fields(record, resolver) do        
        IO.inspect record
        upset_resolver = process_base_fields(record, resolver)
        resolve_record = process_regular_keys(upset_resolver, record)

        Map.put(upset_resolver, :resolved, MapSet.put(upset_resolver.resolved, resolve_record))
    end


    def process_base_fields(rec_struct, resolver) do
        resolver        
        |> base_bn?(rec_struct)        
        |> base_bu?(rec_struct)
        |> base_bt?(rec_struct)
        
        #|> stack_bv?(record)
        #|> stack_bs?(record)
        #|> stack_bver?(record)
    end

    def process_regular_keys(resolver, record) do
        %ResolveRecord{            
            n: resolve_name(resolver, record),
            u: resolve_unit(resolver, record),
            t: resolve_time(resolver, record),
        }   
    end

    def base_bn?(resolver, %{ bn: bn }), do: %{ resolver | bn: bn }
    def base_bn?(resolver, _), do: resolver

    def base_bu?(resolver, %{ bu: bu }), do: %{ resolver | bu: bu }
    def base_bu?(resolver, _), do: resolver

    def base_bt?(resolver, %{ bt: bt }), do: %{ resolver | bt: bt }
    def base_bt?(resolver, _), do: resolver

    def resolve_name(%{ bn: bn}, %{ n: n }), do: "#{bn}#{n}"
    def resolve_name(%{ bn: bn}, _), do: bn
    def resolve_name(_, %{ n: n }), do: n        

    def resolve_unit(%{ bu: _bu}, %{ u: u }), do: u
    def resolve_unit(%{ bu: bu}, _), do: bu
    def resolve_unit(_, %{ u: u }), do: u      

    def resolve_time(%{ bt: _bt}, %{ t: t }), do: t
    def resolve_time(%{ bt: bt}, _), do: bt
    def resolve_time(_, %{ t: t }), do: t    

    def increment_record_counter(stack = %{ number_records: number_records }), do: %{ stack | number_records: number_records + 1 } 

    def to_compact_map(map) do
        map
        |> Enum.reject(fn({_, v}) -> v == nil end)
        |> Enum.into(%{})
    end
end