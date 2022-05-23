alias Zapp.BenchmarkTests, as: Tests

#TODO: consider parrallelising Zapp calls with a macro which collects and fires off as tasks
Benchee.run(
  %{
    "zapp_module_get_1_var_100_modules" => Tests.zapp_module_get_1_var_in_many_modules(100),
    "app_get_1_var_100_modules" => Tests.app_module_get_1_var_in_many_modules(100),
    "zapp_100_puts_1_module" => Tests.zapp_put_many_vars_in_one_module(100),
    "app_100_puts_1_module" => Tests.app_put_many_vars_in_one_module(100),
    "zapp_1_put_100_modules" => Tests.zapp_put_one_var_in_many_modules(100),
    "app_1_puts_100_modules" => Tests.app_put_one_var_in_many_modules(100),
    "zapp_get_100_vars_1_module" => Tests.zapp_get_many_vars_in_one_module(100),
    "zapp_module_get_100_vars_1_module" => Tests.zapp_module_get_many_vars_in_one_module(100),
    "app_get_100_vars_1_module" => Tests.app_get_many_vars_in_one_module(100)
    #TODO: add setting map tests
      }, formatters: [
    Benchee.Formatters.HTML
  ]
)