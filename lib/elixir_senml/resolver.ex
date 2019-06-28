defmodule ElixirSenml.Resolver do
    alias ElixirSenml.Record

    # keep the state during the resolver loop process
    defstruct(
        number_records: 0,
        bn: nil,
        bt: nil,
        bu: nil,
        bv: nil,
        bs: nil,
        bver: nil,
        resolved: MapSet.new(),
    )    

    # resolve Senml payload
    # needs to add to guards to assure that the payload is not empty and it's a JSON format
    # payload = [{},{},...]
    def start_resolve(payload) do      
        stack = %ElixirSenml.Resolver{}   
        Poison.decode!(payload, as: [%Record{}])
        |> resolve(stack)
    end
        
    # In case the Poison.decode returns an error
    def resolve(error = {:error, _}), do: error

    def resolve([record|records], stack) do
        resolve = %ElixirSenml.Resolve{}
        stack_bn?(stack, Map.has_key?(record, :bn), Map.get(record, :bn))
        |> IO.inspect
        |> resolve_name(record.n, stack.bn, resolve)
        |> IO.inspect
        
        resolve(records, Map.put(stack, :resolved, MapSet.put(stack.resolved, resolve)))        
    end

    def resolve([], stack), do: {:ok, stack}        

    # to refactor since the stack_* pattern is clear
    def stack_bn?(stack, true, key_value), do: Map.put(stack, :bn, key_value)
    def stack_bn?(stack, true, nil), do: stack
    def stack_bn?(stack, false, _), do: stack

    def resolve_name(_, nil, nil, _), do: {:error, "invalid base_name and name values"}
    def resolve_name(stack, name = nil, base_name, resolve), do: Map.put(stack, :resolved, MapSet.put(stack.resolved, Map.put(resolve, :n, base_name)))
    def resolve_name(stack, name, base_name = nil, resolve), do: Map.put(stack, :resolved, MapSet.put(stack.resolved, Map.put(resolve, :n, name)))
    def resolve_name(stack, name, base_name, resolve), do: Map.put(stack, :resolved, MapSet.put(stack.resolved, Map.put(resolve, :n, "#{base_name}#{name}")))
end