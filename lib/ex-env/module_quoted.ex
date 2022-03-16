defmodule ExEnv.ModuleQuoted do

    defstruct clause_definitions: [], mod_name: nil


    # TODO: add Genserver for maintaining this state

    defmodule Def do
        defstruct [:match_atom, :return_value]
    end



    # add custom guard clause for making sure only valid types passed to add definition

    def add_definition(mod_quoted = %__MODULE__{clause_definitions: defs}, new_def = %__MODULE__.Def{match_atom: new_def_match}) do
        without_existing = Enum.reject(defs, fn %__MODULE__.Def{match_atom: match_atom} -> new_def_match == match_atom end)
        %__MODULE__{mod_quoted | clause_definitions: [new_def | without_existing ]}
    end

    def module_quoted(%__MODULE__{clause_definitions: defs, mod_name: name}) do
        body = defs |> Enum.map(&clause_quoted/1) |> Enum.reduce(&accumulate_quotes/2) 
        quote do
            defmodule unquote(Module.concat(ExEnv, name)) do
                unquote(body)
            end
        end
    end

    defp accumulate_quotes(quoted, acc) do
         quote do
            unquote(acc)
            unquote(quoted)
         end
    end

    defp clause_quoted(%__MODULE__.Def{match_atom: match_atom, return_value: return_val}) do
        quote do
            def env(unquote(match_atom)), do: unquote(return_val)
        end
    end
end