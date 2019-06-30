defmodule ElixirSenml.ResolverStatus do
    alias ElixirSenml.Record

    # keep the state during the resolver loop process
    defstruct(
        number_records: 0,
        bn: nil,
        bt: nil,
        bu: nil,
        bv: nil,
        bs: nil,
        bver: nil
        #resolved: MapSet.new(),
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
        # stack = %ElixirSenml.ResolverStatus{}
        Enum.reduce(records, %ElixirSenml.ResolverStatus{}, fn record, stack ->
            # remove keys with nil values.
            Map.from_struct(record)
            |> to_compact_map()
            |> process_base_keys(stack)
            |> increment_record_counter()            
        end)
    end
    def resolve([], _), do: { :error, "empty payload"}    
    

    def process_base_keys(map, stack) do
        stack
        |> stack_bn?(map)
        |> stack_bt?(map)
        |> stack_bu?(map)
        |> stack_bv?(map)
        |> stack_bs?(map)
        |> stack_bver?(map)
    end

    def stack_bn?(stack, %{ bn: bn }), do: %{ stack | bn: bn }
    def stack_bn?(stack, _), do: stack

    def stack_bt?(stack, %{ bt: bt }), do: %{ stack | bt: bt }
    def stack_bt?(stack, _), do: stack

    def stack_bu?(stack, %{ bu: bu }), do: %{ stack | bu: bu }
    def stack_bu?(stack, _), do: stack

    def stack_bv?(stack, %{ bv: bv }), do: %{ stack | bv: bv }
    def stack_bv?(stack, _), do: stack

    def stack_bs?(stack, %{ bs: bs }), do: %{ stack | bs: bs }
    def stack_bs?(stack, _), do: stack

    def stack_bver?(stack, %{ bver: bver }), do: %{ stack | bver: bver }
    def stack_bver?(stack, _), do: stack

    def increment_record_counter(stack = %{ number_records: number_records }), do: %{ stack | number_records: number_records + 1 } 

    def to_compact_map(map) do
        map
        |> Enum.reject(fn({_, v}) -> v == nil end)
        |> Enum.into(%{})
    end
end