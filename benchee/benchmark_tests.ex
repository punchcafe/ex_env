defmodule Zapp.BenchmarkTests do
    
    def zapp_put_many_vars_in_one_module(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)
        fn -> large_atom_key_value_set |> Enum.map(fn {key, val} -> Zapp.put(LargeStringSet, key, val) end) end
    end

    def app_put_many_vars_in_one_module(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)
        fn -> large_atom_key_value_set |> Enum.map(fn {key, val} -> Application.put_env(LargeStringSet, key, val) end) end
    end

    def zapp_put_one_var_in_many_modules(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("ATestModule#{number}"), number} end)
        fn -> large_atom_key_value_set |> Enum.map(fn {mod, val} -> Zapp.put(mod, :a_key, val) end) end
    end

    def app_put_one_var_in_many_modules(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("ATestModule#{number}"), number} end)
        fn -> large_atom_key_value_set |> Enum.map(fn {mod, val} -> Application.put_env(mod, :a_key, val) end) end
    end

    def zapp_get_many_vars_in_one_module(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)
        large_atom_key_value_set |> Enum.each(fn {key, val} -> Zapp.put(ZappLargeStringSetForReaingManyToOne, key, val) end)
        fn -> large_atom_key_value_set |> Enum.each(fn {key, val} -> Zapp.fetch_env(LargeStringSetForReaingManyToOne, key) end) end
    end

    def zapp_module_get_many_vars_in_one_module(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)
        large_atom_key_value_set |> Enum.each(fn {key, val} -> Zapp.put(ZappModuleLargeStringSetForReaingManyToOne, key, val) end)
        fn -> large_atom_key_value_set |> Enum.each(fn {key, val} -> Zapp.ZappModuleLargeStringSetForReaingManyToOne.env(key) end) end
    end

    def app_get_many_vars_in_one_module(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("key_#{number}"), number} end)
        large_atom_key_value_set |> Enum.each(fn {key, val} -> Application.put_env(AppLargeStringSetForReaingManyToOne, key, val) end)
        fn -> large_atom_key_value_set |> Enum.each(fn {key, val} -> Application.get_env(AppLargeStringSetForReaingManyToOne, key) end) end
    end

    def app_module_get_1_var_in_many_modules(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("#{RandomWordModuleNumber}#{number}"), number} end)
        Enum.each(large_atom_key_value_set, fn {module, value} -> Application.put_env(module, :a_key, value) end)
        fn -> large_atom_key_value_set |> Enum.each(fn {module, val} -> Application.fetch_env(module, :a_key) end) end
    end

    def zapp_module_get_1_var_in_many_modules(number_of_vars) do
        large_atom_key_value_set = 0..number_of_vars |> Enum.map(fn number -> {String.to_atom("#{RandomWordModuleNumber}#{number}"), number} end)
        large_atom_set = large_atom_key_value_set |> Enum.map(fn {module, val} -> 
            Zapp.put(module, :a_key, val) 
            {Module.concat(Zapp, module), val}
        end)
        fn -> large_atom_set |> Enum.each(fn {module, val} -> module.env(:a_key) end) end
    end
    
end